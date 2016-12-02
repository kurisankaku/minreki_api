require 'active_support/concern'

# Api base settings.
module ApiSettings
  extend ActiveSupport::Concern

  included do
    version 'v1', using: :header, vendor: 'minreki', strict: true, cascade: false
    format :json
  end
end
