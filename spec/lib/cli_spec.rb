require 'gojira/cli'
require 'rspec'
require 'yaml'

describe Gojira::Cli do
  let(:test_config_file) { File.expand_path('spec/test_data/config.yml') }
  let(:test_date) { '10/04/2019' }

  before do
    @test_config = Gojira::Config.new(test_config_file)
    allow(File).to receive(:expand_path).with('~/.gojira.yml').and_return(test_config_file)
  end

  context 'today_summary' do
    it 'Should print a summary of the current days time booked' do
      jira_day_double = double('JiraDay')
      allow(Gojira::JiraDaySummary).to receive(:new).with(anything, test_date, @test_config.jira_username).and_return(jira_day_double)
      date_double = double('Date')
      allow(Time).to receive(:now).and_return(date_double)
      allow(date_double).to receive(:strftime).with('%d/%m/%Y').and_return(test_date)

      expect(Gojira::Config).to receive(:new).and_call_original
      expect(Gojira::JiraRequest).to receive(:new).with(@test_config.jira_host, @test_config.jira_username, @test_config.jira_api_key)
      expect(jira_day_double).to receive(:calculate_missing_time)
      expect(jira_day_double).to receive(:print_booked_summary)

      Gojira::Cli.today_summary
    end
  end

  context 'book_time' do
    it 'Should book time to ticket for current day with passed arguments' do
      test_date_time = '2019-04-10T23:05:00.000+0000'
      jira_request_double = double('JiraRequest')
      allow(Gojira::JiraRequest).to receive(:new).with(
        @test_config.jira_host, @test_config.jira_username, @test_config.jira_api_key
      ).and_return(jira_request_double)
      date_double = double('Date')
      allow(Time).to receive(:now).and_return(date_double)
      allow(date_double).to receive(:strftime).with('%Y-%m-%dT23:05:00.000+0000').and_return(test_date_time)

      expect(Gojira::Config).to receive(:new).and_call_original
      expect(jira_request_double).to receive(:book_time_to_issue).with('KEY-999', '15m', test_date_time)

      Gojira::Cli.book_time('KEY-999', '15m')
    end
  end

  context 'fill_date' do
    it 'Should call bucket_fill_day with correct dry run' do
      expect(Gojira::Cli).to receive(:fill_date).with(test_date, true)

      Gojira::Cli.fill_date(test_date, true)
    end

    it 'Should call bucket_fill_day with correct not dry run' do
      expect(Gojira::Cli).to receive(:fill_date).with(test_date, false)

      Gojira::Cli.fill_date(test_date, false)
    end
  end

  context 'bucket_fill_day' do
    it 'Should print summary of how time will be filled if dry run' do
      jira_bucket_task_double = double('JiraBucketTasks')
      allow(Gojira::JiraBucketTasks).to receive(:new).with(anything, test_date).and_return(jira_bucket_task_double)
      jira_day_double = double('JiraDay')
      allow(Gojira::JiraDaySummary).to receive(:new).with(anything, test_date, @test_config.jira_username).and_return(jira_day_double)
      allow(jira_day_double).to receive(:calculate_missing_time)
      allow(jira_day_double).to receive(:missing_seconds).and_return(900)

      expect(Gojira::Config).to receive(:new).and_call_original
      expect(Gojira::JiraRequest).to receive(:new).with(@test_config.jira_host, @test_config.jira_username, @test_config.jira_api_key)
      expect(jira_bucket_task_double).to receive(:populate_bucket_tasks).with(@test_config.jira_bucket_tasks)
      expect(jira_bucket_task_double).to receive(:compute_missing_time).with(900)
      expect(jira_bucket_task_double).to receive(:print_bucket_summary)
      expect(jira_bucket_task_double).to_not receive(:book_missing_time)

      Gojira::Cli.bucket_fill_day(test_date, true)
    end

    it 'Should print summary of how time will be filled if not dry run' do
      jira_bucket_task_double = double('JiraBucketTasks')
      allow(Gojira::JiraBucketTasks).to receive(:new).with(anything, test_date).and_return(jira_bucket_task_double)
      jira_day_double = double('JiraDay')
      allow(Gojira::JiraDaySummary).to receive(:new).with(anything, test_date, @test_config.jira_username).and_return(jira_day_double)
      allow(jira_day_double).to receive(:calculate_missing_time)
      allow(jira_day_double).to receive(:missing_seconds).and_return(900)

      expect(Gojira::Config).to receive(:new).and_call_original
      expect(Gojira::JiraRequest).to receive(:new).with(@test_config.jira_host, @test_config.jira_username, @test_config.jira_api_key)
      expect(jira_bucket_task_double).to receive(:populate_bucket_tasks).with(@test_config.jira_bucket_tasks)
      expect(jira_bucket_task_double).to receive(:compute_missing_time).with(900)
      expect(jira_bucket_task_double).to receive(:print_bucket_summary)
      expect(jira_bucket_task_double).to receive(:book_missing_time)

      Gojira::Cli.bucket_fill_day(test_date, false)
    end
  end
end
