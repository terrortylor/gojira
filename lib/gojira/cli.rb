# require 'rubygems'
# require './lib/config'
# require './lib/jira_request'
# require './lib/jira_day'
# require './lib/jira_bucket_tasks'

module Gojira
  # Helper class for exposing command line methods
  class CLI
    class << self
      def today_summary
        puts 'in today summary'
        # config = Config.instance
        # jira_request = JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
        #
        # date = '10/04/2019'
        # jira_day = JiraDay.new(jira_request, date, config.jira_username)
        # jira_day.calculate_missing_time
        # jira_day.print_booked_summary
      end
    end
  end
end
