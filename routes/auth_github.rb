require "rest-client"

class MyApp < Sinatra::Base

    # Redirect user to Github OAuth authorization page
    get "/auth/github" do
        redirect to("https://github.com/login/oauth/authorize?approval_prompt=force&scope=repo&client_id=#{ENV["GITHUB_APP_ID"]}")
    end

    # Callback for user authetication info
    get "/auth/github/callback" do

        # Get the code set in the session by Github OAuth to exchange it for an access token
        session_code = request.env["rack.request.query_hash"]["code"]
        parameters = { client_id: ENV["GITHUB_APP_ID"], client_secret: ENV["GITHUB_APP_SECRET"], code: session_code }
        result = RestClient.post("https://github.com/login/oauth/access_token", parameters, accept: :json)
        credentials = JSON.parse(result)

        # Store user token on session and redirect to home page
        session[:github_token] = credentials["access_token"]
        redirect to("/")
    end
end
