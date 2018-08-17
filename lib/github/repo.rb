module Github
  class Repo
    def initialize(client, user_name, repo_name)
      @client = client
      @user_name = user_name
      @repo_name = repo_name
    end

    attr_reader :client, :user_name, :repo_name

    def full_name
      "#{user_name}/#{repo_name}"
    end

    def pulls(options={})
      payload = client.get_json("repos/#{full_name}/pulls")
      pulls = payload.map do |info|
        Pull.new(client, full_name, info: info)
      end
      # github's filtering options are nonexistent
      if creator = options[:creator]
        pulls.reject! do |pull|
          pull.creator_name != creator
        end
      end
      pulls
    end

    def pull(pull_id)
      info = client.get_json("repos/#{full_name}/pulls/#{pull_id}")
      Pull.new(client, full_name, info: info)
    end
  end
end
