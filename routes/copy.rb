require_relative "../helpers/copy_handler"

class MyApp < Sinatra::Base

    # Perfom copy of issues from Gitlab to Github selected repositories,
    #   using authenticated user tokens in session
    post "/copy" do
        gitlab_token = session[:gitlab_token]
        github_token = session[:github_token]

        gitlab_repo = params["gitlab_repo"].to_i
        github_repo = params["github_repo"].to_i
        new_issues = CopyHandler.gitlab_to_github(gitlab_token, gitlab_repo, github_token, github_repo)

        erb :done, { locals: {issue_list: new_issues} }
    end
end
