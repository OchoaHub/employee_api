class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.string :email,      null: false
      t.date   :date_of_birth, null: false
      t.string :phone_number,  null: false
      t.datetime :registration_complete, null: false

      t.timestamps
    end
    add_index :employees, :email, unique: true
  end
end
