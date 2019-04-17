require 'gojira/config'
require 'gojira/jira_request'
require 'gojira/jira_day_summary'
require 'gojira/jira_bucket_tasks'
require 'gojira/jira_daily_tasks'

module Gojira
  # Helper class for exposing command line methods
  class Cli
    class << self
      def today_summary
        config = Gojira::Config.new
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        date = Time.now.strftime('%d/%m/%Y')
        jira_day = JiraDaySummary.new(jira_request, date, config.jira_username)
        jira_day.calculate_missing_time
        jira_day.print_booked_summary
      end

      def book_time(key, time)
        config = Gojira::Config.new
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        date_time = Time.now.strftime('%Y-%m-%dT23:05:00.000+0000')
        jira_request.book_time_to_issue(key, time, date_time)
      end

      def fill_date(date, dry_run)
        bucket_fill_day(date, dry_run)
      end

      def bucket_fill_day(date, dry_run)
        config = Gojira::Config.new
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        jira_day = JiraDaySummary.new(jira_request, date, config.jira_username)
        jira_day.calculate_missing_time
        daily_tasks = Gojira::JiraDailyTasks.new(jira_request, date)
        daily_tasks.populate_daily_tasks(config.jira_daily_tasks, jira_day.issues)
        daily_tasks.print_summary
        daily_tasks.book_daily_tasks unless dry_run
        bucket_tasks = Gojira::JiraBucketTasks.new(jira_request, date)
        bucket_tasks.populate_bucket_tasks(config.jira_bucket_tasks)
        bucket_tasks.compute_missing_time(jira_day.missing_seconds)
        bucket_tasks.print_bucket_summary
        bucket_tasks.book_missing_time unless dry_run
      end
    end
  end
end
