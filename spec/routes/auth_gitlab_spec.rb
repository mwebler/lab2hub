require "rack/test"
require_relative "../../app.rb"
require_relative "./spec_helper"

describe "Sinatra App github authentication routes" do
    include Rack::Test::Methods
    include ClientStub

    def app
        MyApp.new
    end

    describe "on auth callback called" do
        before do
            # as the callback redirect to home, we need to stub github client as well
            stub_gitlab_client

            stub_request(:post, "https://gitlab.com/oauth/token")
                .with(body: including("code=gitlabcode"))
                .to_return(body: {access_token: "gitlab-access-token"}.to_json)

            @response = get "/auth/gitlab/callback?code=gitlabcode"
        end

        it "should redirect to home after retrieving access token" do
            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.path).to eq("/")
        end

        it "should set user token on session after redirection" do
            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.session).to eq({gitlab_token: "gitlab-access-token"})
        end
    end

    describe "on gitlab authentication request" do
        it "should redirect user to gitlab auth page" do
            @response = get "/auth/gitlab"

            expect(@response.redirect?).to be true
            follow_redirect!
            expect(last_request.host).to eq("gitlab.com")
            expect(last_request.path).to eq("/oauth/authorize")
        end
    end
end
