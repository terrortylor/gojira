require 'date'
require 'rainbow'

module Gojira
  # Class to calculate time missing in a day
  # and assign time to a series of bucket tasks
  class JiraDaySummary
    SECONDS_IN_DAY = 28_800
    Issue = Struct.new(:issue_key, :summary, :time_booked)
    attr_reader :date, :issues, :total_seconds, :missing_seconds

    def initialize(jira_request, date, email_address)
      @jira_request = jira_request
      # Convert data format from d/m/Y to Y/m/d
      @date = Date.strptime(date, '%d/%m/%Y').strftime('%Y/%m/%d')
      @issues = []
      @total_seconds = 0
      @email_address = email_address
      @missing_seconds = SECONDS_IN_DAY
    end

    def calculate_missing_time
      response = @jira_request.tickets_booked_time_to_day(@date)
      raise "Response not 200, can't calculate missing time" unless response.code == 200

      body = JSON.parse(response.body)
      @total_seconds = populate_issues(body)
      @missing_seconds -= @total_seconds
      @missing_seconds = 0 if @missing_seconds < 0
    end

    def print_booked_summary
      # TODO: Date should not be stupid american format
      puts Rainbow("\tDate:\t\t\t").green + @date
      puts Rainbow("\tFound Issues:\t\t").green + @issues.size.to_s
      @issues.each do |issue|
        puts "\tKey: #{issue.issue_key}\tTime booked: #{seconds_to_time(issue.time_booked)}\tSummary: #{issue.summary}"
      end
      puts Rainbow("\tTotal time booked:\t").green + seconds_to_time(@total_seconds)
      puts Rainbow("\tTotal time to book:\t").green + seconds_to_time(SECONDS_IN_DAY)
      puts Rainbow("\tMissing time:\t\t").green + seconds_to_time(@missing_seconds)
    end

    def request_issue_worklog(issue_key)
      response = @jira_request.get_issue_worklog(issue_key)
      raise "Response not 200, can't get issue: #{issue_key}" unless response.code == 200

      JSON.parse(response.body)
    end

    def seconds_to_time(seconds)
      Time.at(seconds).utc.strftime('%H:%M:%S')
    end

    def populate_issues(body)
      total_seconds = 0
      body['issues'].each do |issue_result|
        issue_worklog = request_issue_worklog(issue_result['key'])
        issue_total_seconds = calculate_worklogs(issue_worklog)
        issue_result = Issue.new(issue_result['key'], issue_result['fields']['summary'], issue_total_seconds)
        @issues.push(issue_result)
        total_seconds += issue_total_seconds
      end
      total_seconds
    end

    def calculate_worklogs(issue_worklog)
      issue_total_seconds = 0
      issue_worklog['worklogs'].each do |worklog|
        date = Date.parse(worklog['started'])
        formatted_date = date.strftime('%Y/%m/%d')
        issue_total_seconds += worklog['timeSpentSeconds'] if worklog['author']['emailAddress'].eql?(@email_address) && formatted_date.eql?(@date)
      end
      issue_total_seconds
    end
  end
end
