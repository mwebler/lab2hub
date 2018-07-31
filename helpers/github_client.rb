require "octokit"

# An adapter to talk to Github API (with Octokit)
class GithubClient
    def initialize(token)
        @github = Octokit::Client.new(access_token: token)
        @github.auto_paginate = true
    end

    # Get authenticated user handle
    def get_username
        @github.user.login
    end

    # List repositories for authenticated user
    def get_repositories
        repositories = []
        @github.repos.each do |repo|
            repositories.push({
                id: repo.id,
                name: repo.full_name
            })
        end
        repositories
    end

    # Create an issue and its comments on Github
    def create_issue_on_repository(repository, issue)
        github_issue = @github.create_issue(
            repository, issue[:title], issue[:description], {labels: issue[:labels].join(",")})

        # Add comments to the issue
        issue[:comments].each do |comment|
            @github.add_comment(repository, github_issue.number, comment)
        end

        # Close issue if status is 'closed'
        github_issue = @github.close_issue(repository, github_issue.number) if issue[:isClosed]
        github_issue
    end
end
