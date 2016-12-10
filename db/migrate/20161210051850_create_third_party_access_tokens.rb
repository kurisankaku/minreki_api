class CreateThirdPartyAccessTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :third_party_access_tokens, id: :bigint do |t|
      t.integer :user_id, limit: 8, null: false
      t.string :uid, null: false
      t.string :type, limit: 16, null: false
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.datetime :revoked_at
      t.timestamps null: false
    end

    add_index :third_party_access_tokens, :user_id
    add_foreign_key :third_party_access_tokens, :users, column: :user_id
  end
end
