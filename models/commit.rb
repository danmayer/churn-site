class Commit
  REDIS_KEY = 'churn-commits'

  def self.commits_key(project_name)
    "#{REDIS_KEY}:#{project_name}"
  end

  def self.commits(project_name)
    REDIS.hkeys(commits_key(project_name))
  end

  def self.get_sorted_commits_with_details(project_name)
    commits = commits(project_name)
    sorted_commits = []
    commits.each do |commit|
      sorted_commits << get_commit(project_name, commit)
    end
    sorted_commits.compact.sort{|commit_a, commit_b| commit_b.commit_time <=> commit_a.commit_time }
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

  def commit_time
    begin
      if data['timestamp']
        Time.parse(data['timestamp'])
      else
        Time.parse(data['commit']['committer']['date'])
      end
    rescue
      Time.now
    end
  end

  def message
    if data['message']
      data['message']
    else
      data['commit']['message']
    end
  end

  def author
    if data['author']
      data['author']['login']
    else
      data['commit']['author']['login']
    end
  end

  def formatted_commit_time
    commit_time.strftime("%m/%d/%Y at %I:%M%p")
  end

  def churn_results
    ChurnResult.new(@project_name, @commit)
  end

  def update(data)
    REDIS.hset(commits_key(@project_name), @commit, data.to_json)
    @data = JSON.parse(data.to_json)
  end

  private
  

end
