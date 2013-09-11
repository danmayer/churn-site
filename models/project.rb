class Project
  REDIS_KEY = 'churn-projects'

  def self.projects
    REDIS.hkeys(REDIS_KEY)
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

  private
  

end
