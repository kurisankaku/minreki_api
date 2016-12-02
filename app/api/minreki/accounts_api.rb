module Minreki
  # Account API class.
  class AccountsAPI < Grape::API
    include ApiSettings

    resource :accounts do
      get '/' do
        'Hello World'
      end
    end
  end
end
