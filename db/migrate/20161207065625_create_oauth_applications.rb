class CreateOauthApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false
      t.timestamps null: false
    end

    add_index :oauth_applications, :uid, unique: true
  end
end
