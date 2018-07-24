require "octokit"
require "gitlab"

client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

puts client.user.inspect

g = Gitlab.client(endpoint: "https://gitlab.com/api/v4", private_token: ENV["GITLAB_TOKEN"])

user = g.user

puts user.inspect
