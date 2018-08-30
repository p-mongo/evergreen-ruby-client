class PullPresenter
  extend Forwardable

  def initialize(pull, eg_client, system, repo)
    @pull = pull
    @eg_client = eg_client
    @system = system
    @repo = repo
  end

  attr_reader :pull
  attr_reader :eg_client, :system
  def_delegators :@pull, :[], :repo_full_name, :travis_statuses,
    :evergreen_version_id, :head_branch_name, :success_count, :failure_count,
    :pending_count, :approved?, :review_requested?

  def statuses
    @statuses ||= @pull.statuses.map do |status|
      if status.context == 'continuous-integration/travis-ci/pr' && !@repo.travis?
        nil
      else
        EvergreenStatusPresenter.new(status, @pull, eg_client)
      end
    end.compact
  end

  def take_status(label)
    status = statuses.detect { |s| s['context'] == label }
    if status
      @taken_statuses ||= {}
      @taken_statuses[status.context] = true
    end
    status
  end

  def untaken_statuses
    statuses.reject do |status|
      @taken_statuses && @taken_statuses[status['context']]
    end
  end

  def top_evergreen_status
    status = @pull.top_evergreen_status
    if status
      status = EvergreenStatusPresenter.new(status, @pull, eg_client)
    end
    status
  end

  def evergreen_version
    @evergreen_version ||= Evergreen::Version.new(eg_client, @pull.evergreen_version_id)
  end

  def evergreen_project_id
    system.evergreen_project_for_github_repo!(pull.repo_full_name.split('/').first, pull.repo_full_name.split('/')[1]).id
  end

  def have_rspec_json?
    return @have_rspec_json unless @have_rspec_json.nil?
    @have_rspec_json = !!statuses.detect do |status|
      status.failed? && status.rspec_json_url
    end
  end
end
