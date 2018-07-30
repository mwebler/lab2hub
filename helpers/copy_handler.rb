require_relative "gitlab_client"
require_relative "github_client"

# Handle the copy of issues from a Gitlab to a Github repository
class CopyHandler
    def self.gitlab_to_github(gitlab_token, gitlab_repo, github_token, github_repo)
        gitlab = GitlabClient.new(gitlab_token)
        github = GithubClient.new(github_token)

        gitlab_issues = gitlab.get_repository_issues(gitlab_repo)

        github_issues = []

        gitlab_issues.each do |issue|
            github_issue = github.create_issue_on_repository(github_repo, issue)
            github_issues.push(github_issue)
        end

        github_issues
    end
end
