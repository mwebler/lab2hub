require "gitlab"

# An adapter to talk to Gitlab API
class GitlabClient
    def initialize(token)
        @@GITLAB_MAX_PAGINATION = 100
        @gitlab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: token)
    end

    # Get authenticated user handle
    def get_username
        @gitlab.user.username
    end

    # List authenticated user repositories
    def get_repositories
        projects = []
        @gitlab.projects({membership: true}).auto_paginate do |repo|
            projects.push({
                id: repo.id,
                name: repo.path_with_namespace
            })
        end
        projects
    end

    # List issues for a repository, including all comments
    def get_repository_issues(repository)
        issues = @gitlab.issues(repository, {per_page: @@GITLAB_MAX_PAGINATION})

        issues_list = []
        issues.auto_paginate do |issue|
            issue_to_copy = {
                title: issue.title,
                description: issue.description,
                labels: issue.labels,
                comments: [],
                isClosed: issue.state == "closed"
            }

            comments = @gitlab.issue_notes(issue.project_id, issue.iid, {per_page: @@GITLAB_MAX_PAGINATION})
            comments.auto_paginate do |comment|
                # ignore system notes (i.e. label added, closed/reopened)
                next if comment.system

                # unshift to create a list of comments in ascending order by creation/id
                issue_to_copy[:comments].unshift(comment.body)
            end

            # unshift to create a list of issues in ascending order by creation/id
            issues_list.unshift(issue_to_copy)
        end

        issues_list
    end
end
