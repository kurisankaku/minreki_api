# Bad Request Error.
class BadRequestError < BaseError
  # Fetch status code.
  def status_code
    400
  end

  class << self
    # User not found.
    def user_not_found(field = nil)
      self.new(code: :user_not_found, field: field)
    end
  end
end
