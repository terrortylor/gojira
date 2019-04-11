require 'gojira/config'
require 'gojira/jira_request'
require 'gojira/jira_day'
require 'gojira/jira_bucket_tasks'

module Gojira
  # Helper class for exposing command line methods
  class Cli
    class << self
      def today_summary
        config = Gojira::Config.instance
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        date = Time.now.strftime('%d/%m/%Y')
        jira_day = JiraDay.new(jira_request, date, config.jira_username)
        jira_day.calculate_missing_time
        jira_day.print_booked_summary
      end

      def book_time(key, time)
        config = Gojira::Config.instance
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        date_time = Time.now.strftime('%Y-%m-%dT23:05:00.000+0000')
        jira_request.book_time_to_issue(key, time, date_time)
      end

      def fill_date(date, dry_run)
        bucket_fill_day(date, dry_run)
      end

      def bucket_fill_day(date, dry_run)
        config = Gojira::Config.instance
        jira_request = Gojira::JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        jira_day = JiraDay.new(jira_request, date, config.jira_username)
        jira_day.calculate_missing_time
        fill_day = Gojira::JiraBucketTasks.new(jira_request, date)
        fill_day.populate_bucket_tasks(config.jira_bucket_tasks)
        fill_day.compute_missing_time(jira_day.missing_seconds)
        fill_day.print_bucket_summary
        fill_day.book_missing_time unless dry_run
      end
    end
  end
end
