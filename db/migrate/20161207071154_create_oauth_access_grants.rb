class CreateOauthAccessGrants < ActiveRecord::Migration[5.0]
  def change
    create_table :oauth_access_grants, id: :bigint do |t|
      t.integer :user_id, limit: 8, null: false
      t.integer :application_id, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes
      t.datetime :revoked_at
      t.timestamps null: false
    end

    add_index :oauth_access_grants, :token, unique: true
    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_grants, :users, column: :user_id
  end
end
