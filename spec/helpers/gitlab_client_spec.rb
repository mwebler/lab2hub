require "spec_helper"
require "ostruct"
require_relative "../../helpers/gitlab_client"

describe GitlabClient do
    before(:all) do
        class GitlabPagination
            def initialize(items)
                @items = items
            end
            def auto_paginate
                if block_given?
                    @items.each do |i|
                        yield i
                    end
                else
                    @items
                end
            end
        end
    end

    describe ".get_username" do
        before do
            @gitlab = GitlabClient.new("testtoken")
            allow_any_instance_of(Gitlab::Client).to receive(:user).and_return(
                OpenStruct.new({username: "userhandle"})
            )
        end
        it "returns the user gitlab handle" do
            expect(@gitlab.get_username).to eql("userhandle")
        end
    end

    describe ".get_repositories" do
        context "with 3 repositories" do
            before do
                @gitlab = GitlabClient.new("testtoken")
                allow_any_instance_of(Gitlab::Client).to receive(:projects)
                    .with({membership: true})
                    .and_return(GitlabPagination.new([
                        OpenStruct.new({id: 900, path_with_namespace: "userhandle/repository"}),
                        OpenStruct.new({id: 401, path_with_namespace: "organization/repo"}),
                        OpenStruct.new({id: 908, path_with_namespace: "userhandle/repo"})
                    ]))

                @repos = @gitlab.get_repositories
            end

            it "finds 3 repositories" do
                expect(@repos.size).to eql(3)
            end

            it "returns a list of repositories ids and full names (like org/repo or user/repo)" do
                expect { |b| @repos.each(&b) }.to yield_successive_args(
                    {id: 900, name: "userhandle/repository"}, {id: 401, name: "organization/repo"}, {id: 908, name: "userhandle/repo"})
            end
        end

        context "with no repositories" do
            before do
                @gitlab = GitlabClient.new("testtoken")

                allow_any_instance_of(Gitlab::Client).to receive(:projects)
                    .with({membership: true})
                    .and_return(GitlabPagination.new([]))

                @repos = @gitlab.get_repositories
            end

            it "gets an empty list of repositories" do
                expect(@repos.size).to eql(0)
            end
        end
    end

    describe ".get_repository_issues" do
        context "read repository with 3 issues" do
            before do
                expect_any_instance_of(Gitlab::Client).to receive(:issues)
                    .with("repo", {per_page: 100})
                    .and_return(GitlabPagination.new([
                        OpenStruct.new({iid: 3, project_id: 12, title: "issue 3", description: "open issue", labels: ["bug", "minor"], state: "opened"}),
                        OpenStruct.new({iid: 2, project_id: 12, title: "issue 2", description: "with comments", labels: [], state: "opened"}),
                        OpenStruct.new({iid: 1, project_id: 12, title: "issue 1", description: "closed issue", labels: [], state: "closed"})
                    ]))

                # issue 3: open without comments
                expect_any_instance_of(Gitlab::Client).to receive(:issue_notes)
                    .with(12, 3, {per_page: 100})
                    .and_return(GitlabPagination.new([]))

                # issue 2: open with 2 comments and 1 system comment
                expect_any_instance_of(Gitlab::Client).to receive(:issue_notes)
                    .with(12, 2, {per_page: 100})
                    .and_return(GitlabPagination.new([
                        OpenStruct.new({body: "first comment", system: false}),
                        OpenStruct.new({body: "system note", system: true}),
                        OpenStruct.new({body: "another note", system: false})
                    ]))

                # issue 1: closed without comments
                expect_any_instance_of(Gitlab::Client).to receive(:issue_notes)
                    .with(12, 1, {per_page: 100})
                    .and_return(GitlabPagination.new([]))

                gitlab = GitlabClient.new("testtoken")
                @issues = gitlab.get_repository_issues("repo")
            end

            it "gets issue list in correct order" do
                expect(@issues.map { |i| i[:title] }).to eql(["issue 1", "issue 2", "issue 3"])
            end

            it "gets closed issue correctly" do
                index = @issues.map { |i| i[:title] }.index("issue 1")
                expect(@issues[index][:isClosed]).to eql(true)
            end

            it "get comments in order, ignoring system comments" do
                index = @issues.map { |i| i[:title] }.index("issue 2")
                expect(@issues[index][:comments]).to eql(["another note", "first comment"])
            end
        end
    end

end
