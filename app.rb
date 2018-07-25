require "octokit"
require "gitlab"

hub = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

lab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: ENV["GITLAB_TOKEN"])

GITLAB_REPO = "mwebler/issues"
GITLAB_MAX_PAGINATION=100

GITHUB_REPO = "mwebler/issues"

issues = lab.issues(GITLAB_REPO, {per_page: GITLAB_MAX_PAGINATION})

issues_list = []

issues.auto_paginate do |issue|
    issue_to_copy = {
        title: issue.title,
        description: issue.description,
        labels: issue.labels.join(","),
        comments: [],
        isClosed: issue.state == "closed"
    }

    comments = lab.issue_notes(issue.project_id, issue.iid, {per_page: GITLAB_MAX_PAGINATION})
    comments.auto_paginate do |comment|
        # ignore system notes (i.e. label added, closed/reopened)
        next if comment.system

        issue_to_copy[:comments].unshift(comment.body)
    end

    issues_list.unshift(issue_to_copy)
end

issues_list.each do |issue|

    github_issue = hub.create_issue(
        GITHUB_REPO, issue[:title], issue[:description],
        {labels: issue[:labels]})

    issue[:comments].each { |comment| hub.add_comment(GITHUB_REPO, github_issue.number, comment) }

    hub.close_issue(GITHUB_REPO, github_issue.number) if issue[:isClosed]
end
