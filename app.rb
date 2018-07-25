require "octokit"
require "gitlab"

hub = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

lab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: ENV["GITLAB_TOKEN"])

GITLAB_REPO = "mwebler/issues"
GITLAB_MAX_PAGINATION=100

GITHUB_REPO = "mwebler/issues"

issues = lab.issues(GITLAB_REPO, {per_page: GITLAB_MAX_PAGINATION})

issues.auto_paginate do |issue|
    github_issue = hub.create_issue(
        GITHUB_REPO, issue.title, issue.description,
        {labels: issue.labels.join(",")})

    comments = lab.issue_notes(issue.project_id, issue.iid, {per_page: GITLAB_MAX_PAGINATION})
    comments.auto_paginate do |comment|
        next if comment.system

        hub.add_comment(GITHUB_REPO, github_issue.number, comment.body)
    end

    if issue.state == "closed"
        puts("closing issue #{github_issue.number}")
        hub.close_issue(GITHUB_REPO, github_issue.number)
    end
end
