require "spec_helper"
require "json"
require "ostruct"
require_relative "../../helpers/github_client"

describe GithubClient do
    before(:all) do
        @github = GithubClient.new("testtoken")
    end

    describe ".get_username" do
        before do
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
                allow_any_instance_of(Octokit::Client).to receive(:repos).and_return([])

                @repos = @github.get_repositories
            end

            it "gets an empty list of repositories" do
                expect(@repos.size).to eql(0)
            end
        end
    end
end
