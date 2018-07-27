require "octokit"
require "gitlab"
require "sinatra"
require "rest-client"
require "json"

GITLAB_MAX_PAGINATION=100

use Rack::Session::Cookie, {key: "rack.session",
                            expire_after: 1800, # after 30 minutes
                            secret: ENV["SESSION_SECRET"],
                            httponly: true }

def gitlab_to_github(gitlab_token, gitlab_repo, github_token, github_repo)
    gitlab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: gitlab_token)
    github = Octokit::Client.new(access_token: github_token)

    issues = gitlab.issues(gitlab_repo, {per_page: GITLAB_MAX_PAGINATION})

    issues_list = []

    issues.auto_paginate do |issue|
        issue_to_copy = {
            title: issue.title,
            description: issue.description,
            labels: issue.labels.join(","),
            comments: [],
            isClosed: issue.state == "closed"
        }

        comments = gitlab.issue_notes(issue.project_id, issue.iid, {per_page: GITLAB_MAX_PAGINATION})
        comments.auto_paginate do |comment|
            # ignore system notes (i.e. label added, closed/reopened)
            next if comment.system

            issue_to_copy[:comments].unshift(comment.body)
        end

        issues_list.unshift(issue_to_copy)
    end

    issues_list.each do |issue|

        github_issue = github.create_issue(
            github_repo, issue[:title], issue[:description],
            {labels: issue[:labels]})

        issue[:comments].each { |comment| github.add_comment(github_repo, github_issue.number, comment) }

        github.close_issue(github_repo, github_issue.number) if issue[:isClosed]
    end
end

get "/" do
    user_data = {}
    if session[:gitlab_token]
        lab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: session[:gitlab_token])
        user_data[:gitlab_user] = lab.user.username
        user_data[:gitlab_repos] = []
        lab.projects({membership: true}).auto_paginate do |repo|
            user_data[:gitlab_repos].push({
                id: repo.id,
                name: repo.path_with_namespace
            })
        end
    end
    if session[:github_token]
        hub = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
        user_data[:github_user] = hub.user.username
    end
    github_authenticated = true if session[:github_refresh_token]
    erb :index, {locals: {user_data: user_data} }
end

get "/auth/gitlab" do
    redirect to("https://gitlab.com/oauth/authorize?client_id=#{ENV["GITLAB_APP_ID"]}&redirect_uri=http://localhost:4567/authorized-gitlab&response_type=code&state=MYSTATE")
end

get "/authorized-gitlab" do
    parameters = "client_id=#{ENV["GITLAB_APP_ID"]}&client_secret=#{ENV["GITLAB_APP_SECRET"]}&code=#{params['code']}&grant_type=authorization_code&redirect_uri=http://localhost:4567/authorized-gitlab"
    result = RestClient.post("https://gitlab.com/oauth/token", parameters)
    credentials = JSON.parse(result.body)
    session[:gitlab_token] = credentials["access_token"]
    redirect to("/")
end

post "/copy" do
    gitlab_token = session[:gitlab_token]
    github_token = ENV["GITHUB_TOKEN"]

    gitlab_repo = params['gitlab_repo'].to_i
    github_repo = "mwebler/issues"
    gitlab_to_github(gitlab_token, gitlab_repo, github_token, github_repo)
    "done"
end
