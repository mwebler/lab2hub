module ClientStub
    def stub_gitlab_client
        allow_any_instance_of(GitlabClient).to receive(:get_username)
            .and_return("username")

        allow_any_instance_of(GitlabClient).to receive(:get_repositories)
            .and_return([
                {id: 12, name: "user/project-name"},
                {id: 123, name: "org/repository"}
            ])
    end

    def stub_github_client
        allow_any_instance_of(GithubClient).to receive(:get_username)
                .and_return("userhandle")

        allow_any_instance_of(GithubClient).to receive(:get_repositories)
            .and_return([
                {id: 12, name: "user/repo-name"},
                {id: 123, name: "organization/repo"}
            ])
    end
end
