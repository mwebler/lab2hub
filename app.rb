require "octokit"
require "gitlab"

hub = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

lab = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: ENV["GITLAB_TOKEN"])

GITLAB_REPO = "mwebler/issues"

issues = lab.issues(GITLAB_REPO, {per_page: 3})

issues.auto_paginate do |issue|
    # hub.create_issue("mwebler/issues", issue.title, nil, {labels: "bug, todo, imported"})
    puts("#{issue.id} - #{issue.title}")
    puts("\n")
    puts(issue.labels)
    puts("\n")
    puts(issue.state)
    puts("\n")
    puts(issue.description)
    puts("\n")

    comments = lab.issue_notes(issue.project_id, issue.iid)
    comments.auto_paginate do |comment|
        next if comment.system

        puts("--- comment #{comment.id} ---\n")
        puts(comment.body)
        puts("\n")
    end

    puts("\n")
    puts("\n")
end
