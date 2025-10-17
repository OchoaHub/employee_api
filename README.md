# Diagnostikare (Rails 8, API-only)

API REST para gestionar empleados (CRUD), autenticación JWT y consumo de una API pública de clientes (proxy).

## Requisitos

- Ruby 3.3.x
- Rails 8.x
- SQLite (dev/test)
- Bundler

## Instalación

```bash
bundle install
bin/rails db:setup
bin/rails db:seed
bin/rails server
```

Server local: `http://localhost:3000`
(No existen vistas, solo API)

# Auth

Obtener un ApiKey en consola:
```bash
bin/rails c
ApiKey.create!(name: "local").token
```

Login:
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"api_key":"<API_KEY_TOKEN>"}'
```

# Endpoints

- POST /auth/login (público, retorna JWT)
- GET /employees (lista)
- GET /employees/:id (detalle)
- POST /employees (crear)
- PUT /employees/:id (actualizar)
- DELETE /employees/:id (eliminar)
- GET /clients (lista clientes desde API externa)

## Listar empleados:
```bash
curl http://localhost:3000/employees -H "Authorization: Bearer <JWT>"
```

## Crear empleado:
```bash
curl -X POST http://localhost:3000/employees \
  -H "Authorization: Bearer <JWT>" -H "Content-Type: application/json" \
  -d '{"employee":{"first_name":"Carmen","last_name":"Ibarra","email":"cibarra@example.com","date_of_birth":"1999-01-01","phone_number":"+5215512345678"}}'
```

# Validaciones

- **first_name, last_name, email, date_of_birth, phone_number**: requeridos.
- **email**: único, formato válido para correos.
- **date_of_birth**: formato yyyy-mm-dd.
- **phone_number**: formato E.164 con LADA de Américas (+1, +52, +54, +55, +56, +57, +58).
- **registration_complete**: se asigna automáticamente al crear.

## Errores

- **401 Unauthorized**: { "error": "unauthorized", "message": "..." }
- **404 Not Found**: { "error": "not_found", "message": "..." }
- **422 Unprocessable Entity**: { "error": "unprocessable_entity", "message": "Validación fallida", "details": "..." }
- **500 Internal Server Error**: { "error": "internal_server_error", "message": "..." , "request_id": "..." }


# Pruebas (Minitest)

- Validaciones de Employee
- Autenticación JWT
- CRUD completo de employees

Correr pruebas:
```bash
bin/rails test
```

### Fixtures:
- test/fixtures/api_keys.yml
- test/fixtures/employees.yml

# Decisiones técnicas:

- 1. Rails 8 en API-only/API Mode, ya que solo se solicitaron servicios, no vistas.
- 2. Autenticación con JWT, variables externalizadas como **JWT_SECRET** e integración simple
- 3. Creación de modelo **ApiKey** por ser la forma más sencilla de credenciales entre máquina-máquina.
- 4. Creación de servicio **JwtService** para encapsular métodos **encode/decode** y expiración
- 5. Creación de servicio **Clients::FetchList** para aislar integraciones externas
- 6. Validaciones explícitas para mayor consistencia
- 7. Manejo de errores en **ApplicationController** con **rescue_from** para respuesta JSON consistente
- 8. Agregada una capa de seguridad con **filter_parameters**

## Postman:
```json
{
  "info": {
    "name": "Employee API (Rails 8)",
    "_postman_id": "c4f2f3b1-9f2a-4d0a-9a00-employee-api",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    { "key": "base_url", "value": "http://localhost:3000" },
    { "key": "api_key", "value": "" },
    { "key": "jwt", "value": "" },
    { "key": "employee_id", "value": "" }
  ],
  "item": [
    {
      "name": "Auth - Login (get JWT)",
      "event": [
        {
          "listen": "test",
          "script": {
            "type": "text/javascript",
            "exec": [
              "let body = {};",
              "try { body = pm.response.json(); } catch(e) {}",
              "if (body.token) {",
              "  pm.collectionVariables.set('jwt', body.token);",
              "  pm.test('JWT stored', function(){ pm.expect(pm.collectionVariables.get('jwt')).to.be.a('string'); });",
              "} else {",
              "  pm.test('Token missing', function(){ pm.expect.fail('No token in response'); });",
              "}"
            ]
          }
        }
      ],
      "request": {
        "method": "POST",
        "header": [{ "key": "Content-Type", "value": "application/json" }],
        "url": { "raw": "{{base_url}}/auth/login", "host": ["{{base_url}}"], "path": ["auth", "login"] },
        "body": { "mode": "raw", "raw": "{\n  \"api_key\": \"{{api_key}}\"\n}" }
      }
    },
    {
      "name": "Employees - List",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{jwt}}" }],
        "url": { "raw": "{{base_url}}/employees", "host": ["{{base_url}}"], "path": ["employees"] }
      }
    },
    {
      "name": "Employees - Show",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{jwt}}" }],
        "url": { "raw": "{{base_url}}/employees/{{employee_id}}", "host": ["{{base_url}}"], "path": ["employees", "{{employee_id}}"] }
      }
    },
    {
      "name": "Employees - Create",
      "request": {
        "method": "POST",
        "header": [
          { "key": "Authorization", "value": "Bearer {{jwt}}" },
          { "key": "Content-Type", "value": "application/json" }
        ],
        "url": { "raw": "{{base_url}}/employees", "host": ["{{base_url}}"], "path": ["employees"] },
        "body": {
          "mode": "raw",
          "raw": "{\n  \"employee\": {\n    \"first_name\": \"Jorge\",\n    \"last_name\": \"Ochoa\",\n    \"email\": \"jochoa@example.com\",\n    \"date_of_birth\": \"1999-11-18\",\n    \"phone_number\": \"+523121532493\"\n  }\n}"
        }
      }
    },
    {
      "name": "Employees - Update",
      "request": {
        "method": "PUT",
        "header": [
          { "key": "Authorization", "value": "Bearer {{jwt}}" },
          { "key": "Content-Type", "value": "application/json" }
        ],
        "url": { "raw": "{{base_url}}/employees/{{employee_id}}", "host": ["{{base_url}}"], "path": ["employees", "{{employee_id}}"] },
        "body": {
          "mode": "raw",
          "raw": "{\n  \"employee\": {\n    \"phone_number\": \"+12125551234\"\n  }\n}"
        }
      }
    },
    {
      "name": "Employees - Delete",
      "request": {
        "method": "DELETE",
        "header": [{ "key": "Authorization", "value": "Bearer {{jwt}}" }],
        "url": { "raw": "{{base_url}}/employees/{{employee_id}}", "host": ["{{base_url}}"], "path": ["employees", "{{employee_id}}"] }
      }
    },
    {
      "name": "Clients - List (external API proxy)",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{jwt}}" }],
        "url": { "raw": "{{base_url}}/clients", "host": ["{{base_url}}"], "path": ["clients"] }
      }
    }
  ]
}
```


## Docker

Iniciar docker
```bash
docker compose -f docker-compose.prod.yml --env-file .env.example up --build -d
```

Logs
```bash
docker compose -f docker-compose.prod.yml logs -f app
```

Detener
```bash
docker compose -f docker-compose.prod.yml down
```