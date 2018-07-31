require "rest-client"

class MyApp < Sinatra::Base
    @@REDIRECT_URI="#{ENV["APP_URL"]}auth/gitlab/callback&response_type=code&state=MYSTATE"

    # Redirect user to Gitlab OAuth authorization page
    get "/auth/gitlab" do
        redirect to("https://gitlab.com/oauth/authorize?client_id=#{ENV["GITLAB_APP_ID"]}&redirect_uri=#{@@REDIRECT_URI}")
    end

    # Callback for user authetication info
    get "/auth/gitlab/callback" do

        # Use the code received to retrieve an access token
        parameters = "client_id=#{ENV["GITLAB_APP_ID"]}&client_secret=#{ENV["GITLAB_APP_SECRET"]}&code=#{params['code']}&grant_type=authorization_code&redirect_uri=#{@@REDIRECT_URI}"
        result = RestClient.post("https://gitlab.com/oauth/token", parameters)
        credentials = JSON.parse(result.body)

        # Store user token on session and redirect to home page
        session[:gitlab_token] = credentials["access_token"]
        redirect to("/")
    end

end
