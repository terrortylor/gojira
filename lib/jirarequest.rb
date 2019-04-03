require 'httparty'

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
end
