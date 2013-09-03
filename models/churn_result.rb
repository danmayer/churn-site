class ChurnResult

  MISSING_CHURN_RESULTS = 'churn results missing'
  
  attr_accessor :project_name, :commit, :data

  def initialize(project_name, commit)
    @project_name = project_name
    @commit       = commit
  end
  
  def filename
    filename = "project_results/results_for_#{@project_name}_#{@commit}_churn"
  end
  
  def data
    @data ||= get_file(filename)
    if @data && @data!=''
      @data = JSON.parse(@data)
      #old data wasn't a hash but a string ignore old data
      MISSING_CHURN_RESULTS if @data.is_a(String)
    else
      MISSING_CHURN_RESULTS
    end
  end

  def exist?
    data!=MISSING_CHURN_RESULTS
  end

  def command
    data['cmd_run']
  end

  def exit_status
    data['exit_status']
  end

  def results
    data['results']
  end

end
