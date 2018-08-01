require "rack/test"
require_relative "../../app.rb"

describe "Sinatra App copy issues route" do
    include Rack::Test::Methods

    def app
        MyApp.new
    end

    context "is called with two issues to copy" do
        before do
            allow(CopyHandler).to receive(:gitlab_to_github)
                .with("gitlabtoken", 11, "githubtoken", 22)
                .and_return([
                    {number: 1, title: "first issue", html_url: "https://github/issue1", state: "open"},
                    {number: 2, title: "second issue", html_url: "https://github/issue2", state: "closed"},
                ])

            @response = post "/copy", {gitlab_repo: "11", github_repo: "22"}, "rack.session" => { gitlab_token: "gitlabtoken", github_token: "githubtoken" }
        end

        it "should return a table with the copied issues" do
            expect(@response.body).to include('<td><a href="https://github/issue1" target="_blank">#1 - first issue</a></td>')
            expect(@response.body).to include('<td><a href="https://github/issue2" target="_blank">#2 - second issue</a></td>')
        end
    end
end
