ENV['RACK_ENV'] = 'test'
require 'sinatra'
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))
require 'test/unit'
require 'rack/test'
require 'mocha/setup'

class ChurnResultTest < Test::Unit::TestCase
  
  def test_file_name
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    assert_match "project_results/results_for_#{project_name}_#{commit}_churn", churn_result.filename
  end

  def test_data__missing_result
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:get_file).returns(nil)
    assert_equal ChurnResult::MISSING_CHURN_RESULTS, churn_result.data
  end

  def test_exists__true_case
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:get_file).returns({:fake => 'results'}.to_json)
    assert_equal true, churn_result.exists?
  end

  def test_exists__false_case
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:get_file).returns(nil)
    assert_equal false, churn_result.exists?
  end

  def test_command
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:data).returns({'cmd_run' => 'cmd'})
    assert_equal 'cmd', churn_result.command
  end

  def test_exit_status
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:data).returns({'exit_status' => 0})
    assert_equal 0, churn_result.exit_status
  end

  def test_results
    project_name = 'fake_user/fake_project'
    commit       = 'HEAD'
    churn_result = ChurnResult.new(project_name, commit)
    churn_result.stubs(:data).returns({'results' => 'complete'})
    assert_equal 'complete', churn_result.results
  end

end
