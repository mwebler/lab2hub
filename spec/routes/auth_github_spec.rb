require "rack/test"
require_relative "../../app.rb"
require_relative "./spec_helper"

describe "Sinatra App gitlab authentication routes" do
    include Rack::Test::Methods
    include ClientStub

    def app
        MyApp.new
    end

    describe "on auth callback called" do
        before do
            # as the callback redirect to home, we need to stub github client as well
            stub_github_client

            stub_request(:post, "https://github.com/login/oauth/access_token")
                .with(body: hash_including(code: "githubsession"))
                .to_return(body: {access_token: "github-access-token"}.to_json)

            @response = get "/auth/github/callback?code=githubsession"
        end

        it "should redirect to home after retrieving access token" do
            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.path).to eq("/")
        end

        it "should set user token on session after redirection" do
            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.session).to eq({github_token: "github-access-token"})
        end
    end

    describe "on authentication request" do
        it "should redirect user to github auth page" do
            @response = get "/auth/github"

            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.host).to eq("github.com")
            expect(last_request.path).to eq("/login/oauth/authorize")
        end
    end
end
