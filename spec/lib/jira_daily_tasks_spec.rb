require 'gojira/jira_bucket_tasks'
require 'gojira/jira_daily_tasks'
require 'gojira/jira_request'
require 'rspec'

describe Gojira::JiraDailyTasks do
  let(:bucket_config) do
    [
      { 'name' => 'Bucket task 1', 'issue_key' => 'KEY-999', 'time' => '1h 15m' },
      { 'name' => 'Bucket task 2', 'issue_key' => 'KEY-888', 'time' => '30m' }
    ]
  end
  let(:booked_tasks) do
    [
      Gojira::JiraBucketTasks::BucketIssue.new('Existing Task', 'KEY-999', 5, 900)
    ]
  end
  let(:test_date) { '1/4/2019' }
  let(:jira_request_double) { double('JiraRequest') }
  let(:test_obj) { Gojira::JiraDailyTasks.new(jira_request_double, test_date) }

  before do
    test_obj.populate_daily_tasks(bucket_config, booked_tasks)
  end

  context 'populate_daily_tasks' do
    it 'Should populate list of daily tasks, marking if they have already had time booked too' do
      expect(test_obj.daily_tasks.size).to eq(2)
      expect(test_obj.daily_tasks[0].issue_key).to eq('KEY-999')
      expect(test_obj.daily_tasks[0].booked).to eq(true)
      expect(test_obj.daily_tasks[0].time).to eq('1h 15m')
      expect(test_obj.daily_tasks[1].issue_key).to eq('KEY-888')
      expect(test_obj.daily_tasks[1].booked).to eq(false)
      expect(test_obj.daily_tasks[1].time).to eq('30m')
    end
  end

  context 'book_daily_tasks' do
    it 'Should book time to daily tasks not already booked too' do
      expect(test_obj.daily_tasks[0].booked).to eq(true)
      expect(test_obj.daily_tasks[1].booked).to eq(false)

      allow(jira_request_double).to receive(:book_time_to_issue).with('KEY-888', '30m', '1/4/2019T12:00:00.000+0000')

      test_obj.book_daily_tasks

      expect(test_obj.daily_tasks[0].booked).to eq(true)
      expect(test_obj.daily_tasks[1].booked).to eq(true)
    end
  end
end
