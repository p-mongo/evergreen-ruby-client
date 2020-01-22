module Evergreen
  # When a task has {activated: true} in its info, this is rendered in UI as
  # the task being scheduled. {activated: false} is rendered as the task being
  # "unscheduled".
  class Task
    def initialize(client, id, info: nil)
      @client = client
      @id = id
      @info = info
    end

    attr_reader :client, :id

    def info
      @info ||= client.get_json("tasks/#{id}")
    end

    # Information that the evergreen UI shows, scraped from HTML output
    def ui_info
      @ui_info ||= begin
        resp = client.connection.get("/task/#{id}")
        if resp.status != 200
          raise "Bad status #{resp.status}"
        end
        if resp.body =~ /task_data = (.*)/
          JSON.parse($1)
        else
          raise 'Did not find magic data in response'
        end
      end
    end

    def ui_url
      "https://evergreen.mongodb.com/task/#{id}"
    end

    %w(task agent system all).each do |kind|
      define_method("#{kind}_log_html_url") do
        info['logs']["#{kind}_log"]
      end

      define_method("#{kind}_log_html") do
        resp = client.connection.get(send("#{kind}_log_html_url"))
        if resp.status != 200
          fail resp.status
        end
        resp.body
      end

      define_method("#{kind}_log_url") do
        uri = URI.parse(info['logs']["#{kind}_log"])
        query = CGI.parse(uri.query)
        #query['text'] = 'true'
        uri.query = URI.encode_www_form(query)
        uri.to_s
      end

      define_method("#{kind}_log") do
        resp = client.connection.get(send("#{kind}_log_url"))
        if resp.status != 200
          fail resp.status
        end
        resp.body
      end
    end

    %w(display_name status build_id).each do |m|
      define_method(m) do
        info[m]
      end
    end

    {
      created_at: 'create_time',
      ingested_at: 'ingest_time',
      scheduled_at: 'scheduled_time',
      dispatched_at: 'dispatch_time',
      started_at: 'start_time',
      finished_at: 'finish_time',
    }.each do |m, key|
      define_method(m) do
        v = info[key]
        if v
          Time.parse(v)
        else
          nil
        end
      end
    end

    def running?
      status == 'started'
    end

    def waiting?
      %w(undispatched).include?(status)
    end

    def completed?
      %w(success failed).include?(status)
    end

    def failed?
      %w(failed).include?(status)
    end

    def priority
      info['priority']
    end

    # Sets priority of the task, also activating the task if it was inactive
    # (on the assumption that if the user is setting a priority, the intention
    # is for the task to execute).
    def set_priority(priority)
      client.patch_json("tasks/#{id}", priority: priority, activated: true)
    end

    def artifacts
      (info['artifacts'] || []).map do |artifact|
        Artifact.new(client, info: artifact, task: self)
      end
    end

    # in seconds
    def time_taken
      info['time_taken_ms'] / 1000.0
    end

    def queue_position
      ui_info['min_queue_pos']
    end

    def expected_duration
      # value must be in nanoseconds
      ui_info['expected_duration'] / 1_000_000_000
    end

    def self.normalize_status(status)
      map = {'failure' => 'failed', 'success' => 'passed', 'pending' => 'pending',
        'failed' => 'failed', 'undispatched' => 'waiting', 'started' => 'running',
        # These are travis statuses which for some reason go through
        # the evergreen task code
        'error' => 'failed'}
      map[status].tap do |v|
        if v.nil?
          raise "No map entry for #{status}"
        end
      end
    end

    def normalized_status
      self.class.normalize_status(status)
    end

    def restart
      resp = client.post_json("tasks/#{id}/restart")
    end
  end
end
