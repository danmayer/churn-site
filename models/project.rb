class Project
  REDIS_KEY = 'churn-projects'

  def self.projects
    REDIS.hkeys(REDIS_KEY)
  end

  def self.add_project(name, data)
    REDIS.hset(REDIS_KEY, name, data)
    Project.new(name, project_data)
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

  def initialize(name, data = nil)
    @name = name
    @data = JSON.parse(data)
  end

  def name
    @name
  end

  def update(data)
    REDIS.hset(REDIS_KEY, @name, data)
    @data = JSON.parse(data)
  end

  def commits
    Commit.commits(@name)
  end

  def add_commit(commit, data)
    Commit.add_commit(@name, commit, data)
  end

  private
  

end
