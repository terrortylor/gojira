require 'rubygems'
require './lib/config'
require './lib/jira_request'
require './lib/jira_day'

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

fill_day = JiraDay.new(jira_request, '2019/04/04')
fill_day.calculate_missing_time
