class Commit
  REDIS_KEY = 'churn-commits'

  def self.commits_key(project_name)
    "#{REDIS_KEY}:#{project_name}"
  end

  def self.commits(project_name)
    REDIS.hkeys(commits_key(project_name))
  end

  def self.add_commit(project_name, commit, data)
    REDIS.hset(commits_key(project_name), commit, data.to_json)
  end

  def self.remove_commit(project_name, commit)
    REDIS.hdel(commits_key(project_name), commit)
  end

  def self.get_commit(project_name, commit)
    commit_data = REDIS.hget(commits_key(project_name), commit)
    if commit_data
      Commit.new(project_name, commit, commit_data)
    else
      nil
    end
  end

  def initialize(project_name, commit, data)
    @project_name = project_name
    @commit = commit
    @data = JSON.parse(data)
  end

  def name
    @commit
  end

  def data
    @data
  end

  def churn_results
    "churn"
  end

  def generate_churn_results
  end

  def update(data)
    REDIS.hset(commits_key(@project_name), @commit, data.to_json)
    @data = JSON.parse(data.to_json)
  end

  private
  

end
