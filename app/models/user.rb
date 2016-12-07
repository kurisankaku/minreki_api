# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `integer`          | `not null, primary key`
# **`name`**                    | `string(255)`      | `not null`
# **`uid`**                     | `string(255)`      |
# **`token`**                   | `string(255)`      |
# **`email`**                   | `string(255)`      | `default(""), not null`
# **`encrypted_password`**      | `string(255)`      | `default(""), not null`
# **`reset_password_token`**    | `string(255)`      |
# **`reset_password_sent_at`**  | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`sign_in_count`**           | `integer`          | `default(0), not null`
# **`current_sign_in_at`**      | `datetime`         |
# **`last_sign_in_at`**         | `datetime`         |
# **`current_sign_in_ip`**      | `string(255)`      |
# **`last_sign_in_ip`**         | `string(255)`      |
# **`confirmation_token`**      | `string(255)`      |
# **`confirmed_at`**            | `datetime`         |
# **`confirmation_sent_at`**    | `datetime`         |
# **`unconfirmed_email`**       | `string(255)`      |
# **`failed_attempts`**         | `integer`          | `default(0), not null`
# **`unlock_token`**            | `string(255)`      |
# **`locked_at`**               | `datetime`         |
# **`lock_version`**            | `integer`          | `default(0), not null`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`deleted_at`**              | `datetime`         |
#
# ### Indexes
#
# * `index_users_on_confirmation_token` (_unique_):
#     * **`confirmation_token`**
# * `index_users_on_deleted_at`:
#     * **`deleted_at`**
# * `index_users_on_email` (_unique_):
#     * **`email`**
# * `index_users_on_name` (_unique_):
#     * **`name`**
# * `index_users_on_reset_password_token` (_unique_):
#     * **`reset_password_token`**
# * `index_users_on_unlock_token` (_unique_):
#     * **`unlock_token`**
#

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable
end
