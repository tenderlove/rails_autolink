module RailsAutolink
  VERSION = '1.0.3.1'

  class Railtie < ::Rails::Railtie
    initializer 'rails_autolink' do |app|
      ActiveSupport.on_load(:action_view) do
        require 'rails_autolink/helpers'
      end
    end
  end
end
