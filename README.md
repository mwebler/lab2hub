# lab2hub
> A Ruby app that copy issues from Gitlab to a Github repository

You can copy your issues in 3 simple steps:
1. Authorize the app to have access to your repositories and issues on Gitlab and Github;
2. Select a Gitlab project to copy the issues from.
3. Select one of your Github repositories to copy the issues into.
4. **Run it!** (this one is so simple it doesn't even count as a 4th step)

**You can try a live version on Heroku: https://pacific-atoll-58088.herokuapp.com/**

## How it works
The app uses OAuth to authenticate with both Gitlab and Github.
When you authenticate, the app is given access to your repository data using an access token. This token is never stored in the app and lives just in your browser session (encrypted, in a very secure way)

First, the access tokens are used to get the list of repositories from Gitlab and Github for the authenticated user.

After you select the repositories to copy from/to, the tokens in the session are used again to retrieve the issues from Gitlab. Then the issues are converted to the Github format and saved on Github.

All the issues and its comments are copied between repositories. Even the ones that have been closed.

The issues are copied in the same order they were created in Gitlab. That means issues on Github may not have the same id/number as the ones from Gitlab, but will follow the same numbering order.

> The issues/comments on Github will all going to be owned/created by the authenticated user.

## Dependencies
Make sure you have Ruby 2.2 or later installed.

And Bundler: run  `gem install bundler`.

## Configuration
You will need to have the following variables set on the running environment:
- GITHUB_APP_ID: Your Github OAuth app id
- GITHUB_APP_SECRET: Your Github OAuth app secret
- GITLAB_APP_ID: Your Gitlab OAuth app id
- GITLAB_APP_SECRET: Your Gitlab OAuth app secret
- APP_URL: The host where the app is running (used to set the redirect callbacks). Like `http://localhost:4567/`.
- SESSION_SECRET: The secret for Sinatra session. For more info [check this link](https://github.com/sinatra/sinatra#using-sessions)

Set the following callback URLs on your Github and Gitlab OAuth apps:
- Gitlab: #{APP_URL}/auth/gitlab/callback
- Github: #{APP_URL}/auth/github/callback

See how to [create a Github OAuth app](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/) and [a Gitlab OAuth app](https://docs.gitlab.com/ee/integration/oauth_provider.html) for more info.

The Gitlab app need `api` access and the Github app will need access to repositories.

## Running Locally

```sh
git clone https://github.com/mwebler/lab2hub.git
cd lab2hub
bundle install
bundle exec rackup -p 4567
```

Your app should now be running on [localhost:4567](http://localhost:4567/).

## Running rspec tests
```sh
bundle exec rspec
```

# Contributing
For contributions, please check the [Contributions Guideline](CONTRIBUTIONS.md)

# License
lab2hub is licensed under the [MIT License](LICENSE)