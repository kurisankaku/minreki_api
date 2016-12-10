class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, id: :bigint do |t|
      t.string :name, null: false
      t.string :email, null: false, default: ""
      t.string :password_digest, null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Trackable
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.datetime :locked_at

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false
      t.datetime :deleted_at
    end

    add_index :users, :name,         unique: true
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :deleted_at
  end
end
