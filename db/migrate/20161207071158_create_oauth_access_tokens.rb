class CreateOauthAccessTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :oauth_access_tokens, id: :bigint do |t|
      t.integer :user_id, limit: 8, null: false
      t.integer :application_id, null: false
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.string :scopes
      t.string :previous_refresh_token, null: false, default: ""
      t.datetime :revoked_at
      t.timestamps null: false
    end

    add_index :oauth_access_tokens, :user_id
    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_tokens, :users, column: :user_id
  end
end
