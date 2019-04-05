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
---
jira:
  host: 'https://jira.com'
  username: user@widget.com
  api_key: 123abc
```

## Get Summary of a given Day
The following is an example of calculatng a summary of time booked to a day:
```
config = Config.instance
jira_request = JiraRequest.new(config.jira_host, config.jira_username, config.jira_api_key)
fill_day = FillDay.new(jira_request, '2019/04/04')
fill_day.calculate_missing_time
```
