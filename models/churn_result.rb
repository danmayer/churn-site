require 'churn/churn_calculator'

class ChurnResult
  include ServerFiles
  MISSING_CHURN_RESULTS = 'churn results missing'
  
  attr_accessor :project_name, :commit, :data

  def initialize(project_name, commit)
    @project_name = project_name
    @commit       = commit
  end
  
  def filename
    "project_results/results_for_#{@project_name}_#{@commit}_churn"
  end
  
  def data
    @data ||= begin
                @data = get_file(filename)
                if @data && @data!=''
                  @data = JSON.parse(@data)
                  #old data wasn't a hash but a string ignore old data
                  MISSING_CHURN_RESULTS if @data.is_a?(String)
                  @data
                else
                  MISSING_CHURN_RESULTS
                end
              end
  end
  
  def exists?
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

  def formatted_results
    begin
      Churn::ChurnCalculator.to_s(yaml_results[:churn])
    rescue Psych::SyntaxError
      "error parsing results:\n #{results}"
    end
  end
  
  def yaml_results
    YAML.load(data['results'].gsub(/(.*)---/m,'---'))
  end

  def file_changes
    yaml_results[:churn][:changes].length
  end

end
