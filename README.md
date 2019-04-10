# Gojira
A small app for managing my time in Jira

# Refernce Links
Useful references used when working on this project

* [Ruby http request](https://www.rubyguides.com/2018/08/ruby-http-request/)
* [httparty](https://github.com/jnunemaker/httparty)

# Setup / Run Tests
```
bundle install
bundle exec rake
```

# Usage
## Config File
Depends on having a username and API key to work with Atlassian, these are loaded from a config file: ~/.gojira.yml
```
jira:
  host: 'https://jira.com'
  username: user@widget.com
  api_key: 123abc
  daily_tasks:
      - name: Infra Standup
        issue_key: KEY-99
        time: 15m
  bucket_tasks:
    - name: Done work
      issue_key: KEY-10
      weight: 5
    - name: Not done work
      issue_key: KEY-20
      weight: 1
```
Daily tasks are booked if time hasn't already been booked against them.
The remaining time is booked to the bucket tasks in 15m intervals.
The weighting indicates how to split the time, i.e.:
With 3 hours to book:
 - Done work: 2h 30m
 - Not done work: 30m

## Get Summary of a given Day
The following is an example of calculatng a summary of time booked to a day:
```
config = Config.instance
jira_request = JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
fill_day = FillDay.new(jira_request, '2019/04/04')
fill_day.calculate_missing_time
```
