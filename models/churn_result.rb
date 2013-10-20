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
  
  def write_results(churn_results)
    churn_results = churn_results.to_json unless churn_results.is_a?(String)
    write_file(filename, churn_results)
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
    @formatted_results ||= Churn::ChurnCalculator.to_s(parsed_results[:churn])
  rescue Psych::SyntaxError
    "error parsing results:\n #{results}"
  rescue TypeError
    "error in results:\n #{results}"
  end

  def parsed_results
    if data['churn']
      HashWithIndifferentAccess.new(data)
    else
      yaml_results
    end
  end
  
  def yaml_results
    @yaml_results ||= YAML.load(data['results'].gsub(/(.*)---/m,'---'))
  end

  def file_changes
    parsed_results[:churn][:changes]
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

  def class_changes
    parsed_results[:churn][:class_churn]
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

  def method_changes
    parsed_results[:churn][:method_churn]
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

  def file_changes_count
    file_changes ? file_changes.length : 0
  end

  def class_changes_count
    class_changes ? class_changes.length : 0
  end

  def method_changes_count
    method_changes ? method_changes.length : 0
  end

  def avg_churn_file_count
    #todo normal the hash it is symbols here and string elsewhere
    sum = parsed_results[:churn][:changes].sum{|item| item[:times_changed].to_i}
    (sum.to_f / file_changes_count.to_f).round(2)
  rescue Psych::SyntaxError, TypeError, FloatDomainError
    nil
  rescue TypeError
    nil
  end

  def avg_churn_class_count
    sum = parsed_results[:churn][:class_churn].sum{|item| item["times_changed"].to_i}
    (sum.to_f / class_changes_count.to_f).round(2)
  rescue Psych::SyntaxError, TypeError, FloatDomainError
    nil
  rescue TypeError
    nil
  end

  def avg_churn_method_count
    sum = parsed_results[:churn][:method_churn].sum{|item| item["times_changed"].to_i}
    (sum.to_f / method_changes_count.to_f).round(2)
  rescue Psych::SyntaxError, TypeError, FloatDomainError
    nil
  rescue TypeError
    nil
  end

  def high_churn_file_count
    parsed_results[:churn][:changes].select{|item| item[:times_changed].to_f > avg_churn_file_count.to_f}.length
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

  def high_churn_class_count
    parsed_results[:churn][:class_churn].select{|item| item["times_changed"].to_f > avg_churn_class_count.to_f}.length
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

  def high_churn_method_count
    parsed_results[:churn][:method_churn].select{|item| item["times_changed"].to_f > avg_churn_method_count.to_f}.length
  rescue Psych::SyntaxError, TypeError
    nil
  rescue TypeError
    nil
  end

end
