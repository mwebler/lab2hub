require "rack/test"
require_relative "../../app.rb"
require_relative "./spec_helper"

describe "Sinatra App main page" do
    include Rack::Test::Methods
    include ClientStub

    def app
        MyApp.new
    end

    context "with no user authenticated authentication" do
        before(:all) do
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
            stub_gitlab_client
            @response = get "/", {}, "rack.session" => { gitlab_token: "gitlabtoken" }
        end

        it "displays gitlab re-authentication button" do
            expect(@response.body).to include("Re-Authorize Gitlab")
        end

        it "displays gitlab authenticated user handle" do
            expect(@response.body).to include("Authenticated on Gitlab as username")
        end

        it "displays gitlab user project list select" do
            expect(@response.body).to include('<option value="12">user/project-name</option>')
            expect(@response.body).to include('<option value="123">org/repository</option>')
        end
    end

    context "with user authenticated on Github" do
        before do
            stub_github_client
            @response = get "/", {}, "rack.session" => { github_token: "githubtoken" }
        end

        it "displays github re-authentication button" do
            expect(@response.body).to include("Re-Authorize Github")
        end

        it "displays github authenticated user handle" do
            expect(@response.body).to include("Authenticated on Github as userhandle")
        end

        it "displays github user project list select" do
            expect(@response.body).to include('<option value="12">user/repo-name</option>')
            expect(@response.body).to include('<option value="123">organization/repo</option>')
        end
    end
end
