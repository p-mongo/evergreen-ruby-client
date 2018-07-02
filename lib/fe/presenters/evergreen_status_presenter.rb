class EvergreenStatusPresenter
  extend Forwardable

  def initialize(status, pull, eg_client)
    @status = status
    @pull = pull
    @eg_client = eg_client
  end

  attr_reader :status
  attr_reader :eg_client
  def_delegators :@status, :[], :context

  def build_id
    if @status.context =~ %r,evergreen/,
      File.basename(@status['target_url'])
    else
      # top level build
      nil
    end
  end

  def log_url
    "/pulls/#{@pull['number']}/evergreen-log/#{build_id}"
  end

  def restart_url
    "/pulls/#{@pull['number']}/restart/#{build_id}"
  end

  def evergreen_build
    Evergreen::Build.new(eg_client, build_id)
  end
end
