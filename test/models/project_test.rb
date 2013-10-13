ENV['RACK_ENV'] = 'test'
require 'sinatra'
require File.expand_path(File.join(File.dirname(__FILE__), '../../app'))
require 'test/unit'
require 'rack/test'
require 'mocha/setup'
require 'ostruct'

class ProjectTest < Test::Unit::TestCase

  def test_projects
    REDIS.expects(:hkeys)
    Project.projects
  end
  
  def test_projects_as_json
    request = OpenStruct.new(:url => "http://fakeweb.com/current/path", :path => '/current/path')
    projects = ['faker', 'breaker']
    projects_json = Project.projects_as_json(projects, request)
    expected_results = [{"name"=>"faker", "project_url"=>"http://fakeweb.com/faker.json"},
                        {"name"=>"breaker", "project_url"=>"http://fakeweb.com/breaker.json"}
                       ]
    assert_equal expected_results, JSON.parse(projects_json)
  end

  def test_churn_chart_json
    project = get_fake_project
    chart_data = project.churn_chart_json
    assert_equal ['datasets', 'labels'], chart_data.keys.sort
  end

  private
  
  def get_fake_project
    name = 'charliesome/better_errors'
    REDIS.stubs(:get).with("project_#{name}_chart_data").returns(stub_chart_json)
    Commit.stubs(:get_sorted_commits_with_details).returns(stub_sorted_commits)
    Project.new(name, stub_fake_project_json)
  end

  def stub_sorted_commits
    [
     {}
    ]
  end

  def stub_commits
    ["f692c5e3b5097fa1643b05991a19fa5667b35731",
     "4e1acc702397a5cd9c4df09eb2a280aff8c6f09c",
     "8715818cb74f725f9dc8b497064a2156ea0a5d43",
     "1bccc01fd0adc41e673df5d2e998a4f95cfc068b",
     "6fe96674ecba535626934bded154dc7669c98324",
     "984a1e38834bc3d3161b5293b6239ffd4e7671fe",
     "08e6d3447503a1081b379f3763499c64c2e35422",
     "fe9fbba04582316f08036cb5743d98402af51fa5",
     "8ed3f00a1130c571cb529f734284f6248d6086bd",
     "8e5b7f97953663547a8cc4bb55f1924a2e9eee88",
     "f9c21af7a8b33ebb2d44b66e9d1ed603a8aeecfe",
     "dd2b4ac35a257c2dadff0b73c44fba682374a064",
     "dff1e1ab4ec69acc9f0ab6e45b0fc8308bb9203a",
     "baaffb202d799ae44591c20832440188f4c765b5",
     "8b77134270e4fabeb38d7cd4aa7139dbb7bde19c",
     "ef7d5eb04c0151dcdbeba33e6da600fec08f4471",
     "998f5c5dacc34a72f904ffd1b8a58d537dda70a1",
     "d2055088f2223783766f0dfb88cf22c38d07cf47",
     "bd0283bce4d09e9fe525c60f338b690173a1bacb"]
  end

  def stub_fake_project_json
    "{\"id\":7066560,\"name\":\"better_errors\",\"full_name\":\"charliesome/better_errors\",\"owner\":{\"login\":\"charliesome\",\"id\":179065,\"avatar_url\":\"https://0.gravatar.com/avatar/bcb6acc9d0d9bef99e033b36c3d32ca9?d=https%3A%2F%2Fidenticons.github.com%2F9b5cccda2e7df730754dbb4164e1b17a.png\",\"gravatar_id\":\"bcb6acc9d0d9bef99e033b36c3d32ca9\",\"url\":\"https://api.github.com/users/charliesome\",\"html_url\":\"https://github.com/charliesome\",\"followers_url\":\"https://api.github.com/users/charliesome/followers\",\"following_url\":\"https://api.github.com/users/charliesome/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/charliesome/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/charliesome/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/charliesome/subscriptions\",\"organizations_url\":\"https://api.github.com/users/charliesome/orgs\",\"repos_url\":\"https://api.github.com/users/charliesome/repos\",\"events_url\":\"https://api.github.com/users/charliesome/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/charliesome/received_events\",\"type\":\"User\"},\"private\":false,\"html_url\":\"https://github.com/charliesome/better_errors\",\"description\":\"Better error page for Rails and other Rack apps\",\"fork\":false,\"url\":\"https://api.github.com/repos/charliesome/better_errors\",\"forks_url\":\"https://api.github.com/repos/charliesome/better_errors/forks\",\"keys_url\":\"https://api.github.com/repos/charliesome/better_errors/keys{/key_id}\",\"collaborators_url\":\"https://api.github.com/repos/charliesome/better_errors/collaborators{/collaborator}\",\"teams_url\":\"https://api.github.com/repos/charliesome/better_errors/teams\",\"hooks_url\":\"https://api.github.com/repos/charliesome/better_errors/hooks\",\"issue_events_url\":\"https://api.github.com/repos/charliesome/better_errors/issues/events{/number}\",\"events_url\":\"https://api.github.com/repos/charliesome/better_errors/events\",\"assignees_url\":\"https://api.github.com/repos/charliesome/better_errors/assignees{/user}\",\"branches_url\":\"https://api.github.com/repos/charliesome/better_errors/branches{/branch}\",\"tags_url\":\"https://api.github.com/repos/charliesome/better_errors/tags\",\"blobs_url\":\"https://api.github.com/repos/charliesome/better_errors/git/blobs{/sha}\",\"git_tags_url\":\"https://api.github.com/repos/charliesome/better_errors/git/tags{/sha}\",\"git_refs_url\":\"https://api.github.com/repos/charliesome/better_errors/git/refs{/sha}\",\"trees_url\":\"https://api.github.com/repos/charliesome/better_errors/git/trees{/sha}\",\"statuses_url\":\"https://api.github.com/repos/charliesome/better_errors/statuses/{sha}\",\"languages_url\":\"https://api.github.com/repos/charliesome/better_errors/languages\",\"stargazers_url\":\"https://api.github.com/repos/charliesome/better_errors/stargazers\",\"contributors_url\":\"https://api.github.com/repos/charliesome/better_errors/contributors\",\"subscribers_url\":\"https://api.github.com/repos/charliesome/better_errors/subscribers\",\"subscription_url\":\"https://api.github.com/repos/charliesome/better_errors/subscription\",\"commits_url\":\"https://api.github.com/repos/charliesome/better_errors/commits{/sha}\",\"git_commits_url\":\"https://api.github.com/repos/charliesome/better_errors/git/commits{/sha}\",\"comments_url\":\"https://api.github.com/repos/charliesome/better_errors/comments{/number}\",\"issue_comment_url\":\"https://api.github.com/repos/charliesome/better_errors/issues/comments/{number}\",\"contents_url\":\"https://api.github.com/repos/charliesome/better_errors/contents/{+path}\",\"compare_url\":\"https://api.github.com/repos/charliesome/better_errors/compare/{base}...{head}\",\"merges_url\":\"https://api.github.com/repos/charliesome/better_errors/merges\",\"archive_url\":\"https://api.github.com/repos/charliesome/better_errors/{archive_format}{/ref}\",\"downloads_url\":\"https://api.github.com/repos/charliesome/better_errors/downloads\",\"issues_url\":\"https://api.github.com/repos/charliesome/better_errors/issues{/number}\",\"pulls_url\":\"https://api.github.com/repos/charliesome/better_errors/pulls{/number}\",\"milestones_url\":\"https://api.github.com/repos/charliesome/better_errors/milestones{/number}\",\"notifications_url\":\"https://api.github.com/repos/charliesome/better_errors/notifications{?since,all,participating}\",\"labels_url\":\"https://api.github.com/repos/charliesome/better_errors/labels{/name}\",\"created_at\":\"2012-12-08T11:02:18Z\",\"updated_at\":\"2013-09-26T20:39:08Z\",\"pushed_at\":\"2013-09-25T10:24:05Z\",\"git_url\":\"git://github.com/charliesome/better_errors.git\",\"ssh_url\":\"git@github.com:charliesome/better_errors.git\",\"clone_url\":\"https://github.com/charliesome/better_errors.git\",\"svn_url\":\"https://github.com/charliesome/better_errors\",\"homepage\":\"\",\"size\":1208,\"watchers_count\":3870,\"language\":\"Ruby\",\"has_issues\":true,\"has_downloads\":true,\"has_wiki\":true,\"forks_count\":186,\"mirror_url\":null,\"open_issues_count\":7,\"forks\":186,\"open_issues\":7,\"watchers\":3870,\"master_branch\":\"master\",\"default_branch\":\"master\",\"network_count\":186}"
  end

  def stub_chart_json
    "{\"labels\":[\"06/17/2013\",\"06/26/2013\",\"06/27/2013\",\"06/29/2013\",\"07/09/2013\",\"08/02/2013\",\"08/03/2013\",\"08/05/2013\",\"08/07/2013\",\"08/10/2013\",\"08/18/2013\",\"08/29/2013\",\"08/30/2013\",\"09/03/2013\",\"09/08/2013\",\"09/14/2013\"],\"datasets\":[{\"fillColor\":\"rgba(151,187,205,0.5)\",\"strokeColor\":\"rgba(151,187,205,1)\",\"data\":[0,15,0,13,12,7,12,11,12,11,11,0,0,0,15,15]}]}"
  end

end
