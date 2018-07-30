require "spec_helper"
require "json"
require_relative "../../helpers/github_client"

describe GithubClient do
    before(:all) do
        @github = GithubClient.new("testtoken")
    end

    describe ".get_username" do
        before do
            stub_request(:get, "https://api.github.com/user").
                with(headers: {Authorization: "token testtoken"}).
                to_return(
                    status: 200, 
                    body: JSON.generate({login: "userhandle", id: 1, name: "User Test", email: "user@test.com" }), 
                    headers: {"Content-Type": "application/json"})
        end
        it "returns the user github handle" do
            expect(@github.get_username).to eql("userhandle")
        end
    end

    describe ".get_repositories" do
        before do
            stub_request(:get, "https://api.github.com/user/repos").
                with(query: {per_page: 100}).
                to_return(
                    status: 200,
                    body: JSON.generate([{id: 9999, full_name: "userhandle/repo"}, {id: 5566, full_name: "org/another"}]),
                    headers: {"Content-Type": "application/json", "X-GitHub-Media-Type": "github.v3; param=full; format=json"})
        end
        it "returns a list of repositories ids and full names (like org/repo or user/repo)" do
            repos = @github.get_repositories
            expect(repos).not_to be_empty
            expect(repos.size).to eql(2)
            puts repos.inspect
            expect { |b| repos.each(&b)   }.to yield_successive_args({id: 9999, name: "userhandle/repo"}, {id: 5566, name: "org/another"})
        end
    end
end
