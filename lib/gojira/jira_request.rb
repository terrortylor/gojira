require 'httparty'
require 'uri'

module Gojira
  # Helper class for making calls to Jira
  class JiraRequest
    def initialize(host, username, api_key)
      @host = host
      @accept_header = { Accept: 'application/json' }
      @basic_auth = { username: username, password: api_key }
    end

    def get_issue(issue_id)
      get_request_without_query("/rest/api/3/issue/#{issue_id}")
    end

    def get_issue_worklog(issue_id)
      get_request_without_query("/rest/api/3/issue/#{issue_id}/worklog")
    end

    def tickets_worked_on_this_week
      query = 'worklogDate > startofWeek() AND worklogAuthor = currentUser()'
      HTTParty.get(
        "#{@host}/rest/api/3/search",
        basic_auth: @basic_auth,
        headers: @accept_header,
        query: { jql: query }
      )
    end

    def tickets_booked_time_to_day(date)
      query = "worklogDate = '#{date}' AND worklogAuthor = currentUser()"
      HTTParty.get(
        "#{@host}/rest/api/3/search",
        basic_auth: @basic_auth,
        headers: @accept_header,
        query: { jql: query }
      )
    end

    def book_time_to_issue(key, time, date)
      # puts "Key: #{key} Time: #{time} Date: #{date}"
      HTTParty.post(
        "#{@host}/rest/api/3/issue/#{key}/worklog",
        basic_auth: @basic_auth,
        headers: { 'Content-Type': 'application/json' },
        body: { timeSpentSeconds: time, started: date }.to_json
      )
    end

    private

    def get_request_without_query(path)
      HTTParty.get(
        "#{@host}#{path}",
        basic_auth: @basic_auth,
        headers: @accept_header
      )
    end
  end
end
