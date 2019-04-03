require 'httparty'
require 'uri'

# Helper class for making calls to Jira
class JiraRequest
  def initialize(host, username, api_key)
    @host = host
    @base_headers = { Accept: 'application/json' }
    @basic_auth = { username: username, password: api_key }
  end

  def get_issue(issue_id)
    HTTParty.get(
      "#{@host}/rest/api/3/issue/#{issue_id}",
      basic_auth: @basic_auth,
      headers: @base_headers
    )
  end

  def tickets_worked_on_this_week
    query = 'worklogDate > startofWeek() AND worklogAuthor = currentUser()'
    HTTParty.get(
      "#{@host}/rest/api/3/search",
      basic_auth: @basic_auth,
      headers: @base_headers,
      query: { jql: query }
    )
  end

  def tickets_booked_time_to_day(date)
    query = "worklogDate = '#{date}' AND worklogAuthor = currentUser()"
    HTTParty.get(
      "#{@host}/rest/api/3/search",
      basic_auth: @basic_auth,
      headers: @base_headers,
      query: { jql: query }
    )
  end
end
