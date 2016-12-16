# Bad Request Error.
class BadRequestError < BaseError
  # Fetch status code.
  def status_code
    400
  end
end
