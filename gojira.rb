require 'rubygems'
require './lib/config'
require './lib/jira_request'
require './lib/jira_day'
require './lib/jira_bucket_tasks'

config = Config.instance
# infra_meetings = 'ISD-2087'
jira_request = JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
# response = jira_request.get_issue(infra_meetings)
# # puts response.code
# body = JSON.parse(response.body)
# # puts body['id']
# puts JSON.pretty_generate(body)
# # puts body['worklog']

# response = jira_request.tickets_booked_time_to_day('2019/04/01')
# puts response.code
# body = JSON.parse(response.body)

# puts JSON.pretty_generate(body)
# puts "Issues Found: #{body['total']}"
# body['issues'].each do |issue|
#   puts "#{issue['key']} - #{issue['fields']['summary']}"
# end
# puts JSON.pretty_generate(body)

date = '9/04/2019'
jira_day = JiraDay.new(jira_request, date, config.jira_username)
jira_day.calculate_missing_time
jira_day.print_booked_summary

fill_day = JiraBucketTasks.new(jira_request, date)
fill_day.populate_bucket_tasks(config.jira_bucket_tasks)
fill_day.fill_day(jira_day.missing_seconds)
fill_day.print_bucket_summary

# jira_request.book_time_to_issue('INF-370', 900, "2019-04-6T00:00:00.000+0000")
#
# jira_day.print_booked_summary
