require "rack/test"
require_relative "../../app.rb"

describe "Sinatra App main page" do
    include Rack::Test::Methods

    def app
        MyApp.new
    end

    context "with no user authenticated authentication" do
        before do
            @response = get "/"
        end

        it "displays gitlab authentication button" do
            expect(@response.body).to include("Authorize Gitlab")
        end

        it "displays github authentication button" do
            expect(@response.body).to include("Authorize Github")
        end
    end

    context "with user authenticated on gitlab" do
        before do
            allow_any_instance_of(GitlabClient).to receive(:get_username)
                .and_return("username")
            allow_any_instance_of(GitlabClient).to receive(:get_repositories)
                .and_return([
                    {id: 12, name: "user/project-name"},
                    {id: 123, name: "org/repository"}
                ])
            @response = get "/", {}, "rack.session" => { gitlab_token: "gitlabtoken" }
        end

        it "displays gitlab re-authentication button" do
            expect(@response.body).to include("Re-Authorize Gitlab")
        end

        it "displays gitlab authenticated user handle" do
            expect(@response.body).to include("Already authenticated as username")
        end

        it "displays gitlab user project list select" do
            expect(@response.body).to include('<option value="12">user/project-name</option>')
            expect(@response.body).to include('<option value="123">org/repository</option>')
        end
    end

    context "with user authenticated on Github" do
        before do
            allow_any_instance_of(GithubClient).to receive(:get_username)
                .and_return("userhandle")
            allow_any_instance_of(GithubClient).to receive(:get_repositories)
                .and_return([
                    {id: 12, name: "user/repo-name"},
                    {id: 123, name: "organization/repo"}
                ])
            @response = get "/", {}, "rack.session" => { github_token: "githubtoken" }
        end

        it "displays github re-authentication button" do
            expect(@response.body).to include("Re-Authorize Github")
        end

        it "displays github authenticated user handle" do
            expect(@response.body).to include("Already authenticated as userhandle")
        end

        it "displays github user project list select" do
            expect(@response.body).to include('<option value="12">user/repo-name</option>')
            expect(@response.body).to include('<option value="123">organization/repo</option>')
        end
    end
end
