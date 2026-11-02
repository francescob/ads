# frozen_string_literal: true

# Configure Noticed gem for notifications

# Load custom delivery methods
Rails.application.config.to_prepare do
  # Register custom delivery methods
  Dir[Rails.root.join('app/notifiers/delivery_methods/*.rb')].each do |file|
    require_dependency file
  end
end