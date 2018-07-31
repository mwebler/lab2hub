require "spec_helper"
require "json"
require "ostruct"
require_relative "../../helpers/github_client"

describe GithubClient do
    describe ".get_username" do
        before do
            @github = GithubClient.new("testtoken")
            allow_any_instance_of(Octokit::Client).to receive(:user).and_return(
                OpenStruct.new({login: "userhandle", id: 1, name: "User Test", email: "user@test.com" })
            )
        end
        it "returns the user github handle" do
            expect(@github.get_username).to eql("userhandle")
        end
    end

    describe ".get_repositories" do
        context "with 2 repositories" do
            before do
                @github = GithubClient.new("testtoken")
                allow_any_instance_of(Octokit::Client).to receive(:repos).and_return(
                    [
                        OpenStruct.new({id: 9999, full_name: "userhandle/repo"}),
                        OpenStruct.new({id: 5566, full_name: "org/another"})
                    ]
                )

                @repos = @github.get_repositories
            end

            it "finds 2 repositories" do
                expect(@repos.size).to eql(2)
            end

            it "returns a list of repositories ids and full names (like org/repo or user/repo)" do
                expect { |b| @repos.each(&b) }.to yield_successive_args({id: 9999, name: "userhandle/repo"}, {id: 5566, name: "org/another"})
            end
        end

        context "with no repositories" do
            before do
                @github = GithubClient.new("testtoken")

                allow_any_instance_of(Octokit::Client).to receive(:repos).and_return([])

                @repos = @github.get_repositories
            end

            it "gets an empty list of repositories" do
                expect(@repos.size).to eql(0)
            end
        end
    end

    describe ".create_issue_on_repository" do
        context "create open issue without comments" do
            before do
                expect_any_instance_of(Octokit::Client).to receive(:create_issue)
                .with("repo", "issue title", "issue body", {labels: ""})
                .and_return(
                    OpenStruct.new({number: 1234})
                )
                @github = GithubClient.new("testtoken")
            end

            it "succesfully creates an issue" do
                new_issue = @github.create_issue_on_repository(
                    "repo", {title: "issue title", description: "issue body", isClosed: false, comments: [], labels: []})
                expect(new_issue.number).to be(1234)
            end
        end

        context "create open issue with 2 comments" do
            before do
                expect_any_instance_of(Octokit::Client).to receive(:create_issue)
                    .with("repo name", "another issue", "issue text", {labels: ""})
                    .and_return(
                        OpenStruct.new({number: 111})
                    )

                expect_any_instance_of(Octokit::Client).to receive(:add_comment)
                    .with("repo name", 111, "My first comment")

                expect_any_instance_of(Octokit::Client).to receive(:add_comment)
                    .with("repo name", 111, "Just another comment")

                @github = GithubClient.new("testtoken")
            end

            it "succesfully create two comments in an issue" do
                @github.create_issue_on_repository(
                    "repo name", {title: "another issue", description: "issue text", isClosed: false, comments: ["My first comment", "Just another comment"], labels: []})
            end
        end

        context "create and close an issue" do
            before do
                expect_any_instance_of(Octokit::Client).to receive(:create_issue)
                    .with("repository", "closed issue", "body", {labels: ""})
                    .and_return(
                        OpenStruct.new({number: 111})
                    )

                expect_any_instance_of(Octokit::Client).to receive(:close_issue)
                    .with("repository", 111)

                @github = GithubClient.new("testtoken")
            end

            it "succesfully close an issue" do
                @github.create_issue_on_repository(
                    "repository", {title: "closed issue", description: "body", isClosed: true, comments: [], labels: []})
            end
        end
    end

end
