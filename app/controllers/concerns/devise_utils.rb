# This module based on DeviseController.
# DeviseController includes view components, but This api project doesn't need view.
# So pulled out the components that is going to use from it.
module DeviseUtils

  # Gets the actual resource stored in the instance variable
  def resource
    instance_variable_get(:"@{#resource_name}")
  end

  # Sets the resource creating an instance variable
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  # Proxy to devise map name
  def resource_name
    devise_mapping.name
  end

  # Attempt to find the mapped route for devise based on request path
  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"]
  end

  # Proxy to devise map class.
  def resource_class
    devise_mapping.to
  end

  # Cleanup passwords of object.
  def clean_up_passwords(object)
    object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
  end

  # Gets params of the resource.
  def resource_params
    params.fetch(resource_name, {})
  end
end
