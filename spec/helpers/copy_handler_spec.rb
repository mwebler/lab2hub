require "spec_helper"
require_relative "../../helpers/copy_handler"

describe CopyHandler do
    describe ".gitlab_to_github" do
        before do
            @github = GithubClient.new("testtoken")
            allow_any_instance_of(GitlabClient).to receive(:get_repository_issues)
                .and_return([
                    {title: "issue 1", description: "desc", labels: [], comments: [], isClosed: false},
                    {title: "issue 2", description: "another", labels: ["bug"], comments: ["fixed this"], isClosed: true}
                ])
        end
        it "expects github client to be called with gitlab issues" do
            expect_any_instance_of(GithubClient).to receive(:create_issue_on_repository)
                .with("githubrepo", {title: "issue 1", description: "desc", labels: [], comments: [], isClosed: false})
                .and_return(
                    OpenStruct.new({number: 1})
                )

            expect_any_instance_of(GithubClient).to receive(:create_issue_on_repository)
                .with("githubrepo", {title: "issue 2", description: "another", labels: ["bug"], comments: ["fixed this"], isClosed: true})
                .and_return(
                    OpenStruct.new({number: 2})
                )

            CopyHandler.gitlab_to_github("labtoken", "repo", "hubtoken", "githubrepo")
        end
    end
end
