module Minreki
  # Account API class.
  class AccountsAPI < Grape::API
    include ApiSettings
    resource :accounts do
      version 'v1' do
        get '/' do
          'Hello World'
        end
    end
  end
end
