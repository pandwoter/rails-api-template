# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]

  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest
      t.add_index :email, unique: true

      t.timestamps
    end
  end

end
