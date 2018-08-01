require "sinatra/base"
require_relative "routes/init"

class MyApp < Sinatra::Base
    enable :method_override

    # Enable cookie usage
    use Rack::Session::Cookie, {key: "rack.session",
        expire_after: 1800, # after 30 minutes
        secret: ENV["SESSION_SECRET"],
        httponly: true } unless test?

    configure do
      set :app_file, __FILE__
    end

    configure :development do
      enable :logging, :dump_errors, :raise_errors
    end

    configure :production do
      set :raise_errors, false #false will show nicer error page
      set :show_exceptions, false #true will ignore raise_errors and display backtrace in browser
    end
  end
