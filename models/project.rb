class Project
  PROJECTS_KEY = 'churn-projects'

  def self.projects
    REDIS.hkeys(PROJECTS_KEY)
  end

  def self.add_project(name)
    REDIS.hset(PROJECTS_KEY, name, 'url')
  end

  def self.remove_project(name)
    REDIS.hdel(PROJECTS_KEY, name)
  end

  def self.get_project(name)
    REDIS.hget(PROJECTS_KEY, name)
  end

  private
  

end
