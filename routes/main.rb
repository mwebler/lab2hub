require_relative "../helpers/gitlab_client"
require_relative "../helpers/github_client"

class MyApp < Sinatra::Base

    # Get information about authenticated user and show authentication options
    get "/" do
        user_data = {}
        if session[:gitlab_token]
            lab = GitlabClient.new(session[:gitlab_token])
            user_data[:gitlab_user] = lab.get_username
            user_data[:gitlab_repos] = lab.get_repositories
        end
        if session[:github_token]
            hub = GithubClient.new(session[:github_token])
            user_data[:github_user] = hub.get_username
            user_data[:github_repos] = hub.get_repositories
        end
        erb :index, {locals: {user_data: user_data} }
    end
end
