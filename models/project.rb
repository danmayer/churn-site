class Project
  REDIS_KEY = 'churn-projects'

  def self.projects
    REDIS.hkeys(REDIS_KEY)
  end

  def self.projects_as_json(projects, request)
    projects.map{|proj| {:name => proj, :project_url => "#{request.url.gsub(/#{request.path}/,'')}/#{proj}.json"} }.to_json
  end

  def self.add_project(name, data)
    REDIS.hset(REDIS_KEY, name, data.to_json)
    Project.new(name, data.to_json)
  end

  def self.remove_project(name)
    REDIS.hdel(REDIS_KEY, name)
  end

  def self.get_project(name)
    project_data = REDIS.hget(REDIS_KEY, name)
    if project_data
      Project.new(name, project_data)
    else
      nil
    end
  end

  def initialize(name, data)
    @name = name
    @data = JSON.parse(data)
  end

  def name
    @name
  end

  def update(data)
    REDIS.hset(REDIS_KEY, @name, data.to_json)
    @data = JSON.parse(data.to_json)
  end

  def commits
    @commits ||= Commit.commits(@name)
  end
  
  def sorted_commits
    @sorted_commits ||= Commit.get_sorted_commits_with_details(@name)
  end
  
  def add_commit(commit, data)
    Commit.add_commit(@name, commit, data)
  end

  def as_hash(request)
    {
      :name => name,
      :commits => sorted_commits.map{|commit| {:commit_url => "#{request.url.gsub(/#{request.path}/,'')}/#{name}/commits/#{commit.name}.json" } }
    }
  end

  def churn_chart_json
    chartdata = REDIS.get("project_#{name}_chart_data")
    json_try = true
    begin
      bad_json_data = ['',"\"\"",'""','null','"\"\""']
      if json_try==true && chartdata && !bad_json_data.include?(chartdata.strip)
        chartdata = JSON.parse(chartdata)
      else
        series_labels = []
        series_data = []
        sorted_commits.reverse.map do |commit|
          if !series_labels.include?(commit.short_formatted_commit_datetime)
            churn_results = commit.churn_results 
            if churn_results.exists? && churn_results.file_changes!=nil
              series_labels << commit.short_formatted_commit_datetime
              series_data << churn_results.file_changes_count
            end
          end
        end
        
        chartdata = {
          labels: series_labels,
          datasets: [
                     {
                       fillColor: "rgba(151,187,205,0.5)",
                       strokeColor: "rgba(151,187,205,1)",
                       data: series_data
                     }
                    ]
        }
        
        REDIS.set("project_#{name}_chart_data", chartdata.to_json)
      end
    rescue JSON::ParserError => error
      puts "json error #{error} json looked like: #{chartdata}"
      json_try = false
      retry
    end
    chartdata
  end
  
  def clear_caches
    REDIS.set("project_#{name}_chart_data", nil)
  end

  private
  

end
