source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use mysql2 as the database for Active Record
gem 'mysql2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# logical delete.
gem 'paranoia', '~> 2.2'

# markdown.
gem 'kramdown'

# log format.
gem 'lograge'

# Brings convention over configuration to your JSON generation.
gem 'active_model_serializers', '~> 0.10.0'

# Seed gem.
gem 'seed-fu'

# Simple, efficient background processing.
gem 'sidekiq'

group :development, :test do
  # Use Puma as the app server
  gem 'puma', '~> 3.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Use oauth2 for Api login.
  gem 'oauth2'
  # yardoc.
  gem 'yard'

  # Test framework.
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails'

  # Debug
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'
  gem 'rubocop'
end

group :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'faker'
  gem 'database_cleaner'
  gem 'json_expressions'
  gem 'timecop'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
