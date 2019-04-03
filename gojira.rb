require 'rubygems'
require './lib/config'
require './lib/jirarequest'

config = Config.instance
infra_meetings = 'INF-370'
jira_request = JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
response = jira_request.get_issue(infra_meetings)
puts response.code
body = JSON.parse(response.body)
puts body['id']
puts JSON.pretty_generate(body)
puts body['worklog']
