require 'date'
# require './jira_request'

# Class to calculate time missing in a day
# and assign time to a series of bucket tasks
class FillDay
  SECONDS_IN_DAY = 28_800
  Issue = Struct.new(:key, :summary, :time_booked)
  attr_reader :date, :issues, :total_seconds, :missing_seconds

  def initialize(jira_request, date)
    @jira_request = jira_request
    @date = date
    @issues = []
    @total_seconds = 0
    @missing_seconds = SECONDS_IN_DAY
  end

  def calculate_missing_time
    response = @jira_request.tickets_booked_time_to_day(@date)
    raise "Response not 200, can't calculate missing time" unless response.code == 200

    body = JSON.parse(response.body)
    @total_seconds = populate_issues(body)
    @missing_seconds -= @total_seconds
    print_booked_summary @issues
  end

  def print_booked_summary(issues)
    puts "Day Summary: #{@date}"
    puts "Found Issues: #{issues.size}"
    issues.each do |issue|
      puts "\tKey: #{issue.key} Summary: #{issue.summary} Time booked: #{seconds_to_time(issue.time_booked)}"
    end
    puts "Total time booked: #{seconds_to_time(@total_seconds)}"
    puts "Total time to book: #{seconds_to_time(SECONDS_IN_DAY)}"
    puts "Missing time: #{seconds_to_time(@missing_seconds)}"
  end

  def request_issue(key)
    response = @jira_request.get_issue(key)
    raise "Response not 200, can't get issue: #{key}" unless response.code == 200

    JSON.parse(response.body)
  end

  def seconds_to_time(seconds)
    Time.at(seconds).utc.strftime('%H:%M:%S')
  end

  def populate_issues(body)
    total_seconds = 0
    body['issues'].each do |issue_result|
      issue = request_issue(issue_result['key'])
      issue_total_seconds = calculate_worklogs(issue)
      issue_result = Issue.new(issue_result['key'], issue_result['fields']['summary'], issue_total_seconds)
      @issues.push(issue_result)
      total_seconds += issue_total_seconds
    end
    total_seconds
  end

  def calculate_worklogs(issue)
    issue_total_seconds = 0
    issue['fields']['worklog']['worklogs'].each do |worklog|
      date = DateTime.parse(worklog['started'])
      formatted_date = date.strftime('%Y/%m/%d')
      issue_total_seconds += worklog['timeSpentSeconds'] if formatted_date.eql? @date
    end
    issue_total_seconds
  end
end
