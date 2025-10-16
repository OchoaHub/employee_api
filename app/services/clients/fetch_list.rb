module Clients
  class FetchList
    Client = Struct.new(:id, :name, :email, :company, keyword_init: true)

    def initialize(http: default_http, base_url: ENV.fetch("CLIENTS_API_URL", "https://jsonplaceholder.typicode.com"))
      @http = http
      @base_url = base_url
    end

    def call
      resp = @http.get("#{@base_url}/users")
      raise "Error fetching clients (#{resp.status})" unless resp.success?
      Array(resp.body).map do |u|
        Client.new(
          id: u["id"],
          name: u["name"],
          email: u["email"],
          company: u.dig("company", "name")
        )
      end
    end

    private

    def default_http
      Faraday.new do |f|
        f.response :follow_redirects
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end
  end
end
