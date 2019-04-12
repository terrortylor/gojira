# Gojira
A small app for managing my time in Jira

# Refernce Links
Useful references used when working on this project

* [Ruby http request](https://www.rubyguides.com/2018/08/ruby-http-request/)
* [httparty](https://github.com/jnunemaker/httparty)
* [Atlassian API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/?utm_source=%2Fcloud%2Fjira%2Fplatform%2Frest%2F&utm_medium=302)
* [thor CLI package... it's niiiice](http://whatisthor.com/)

# Development
## Setup / Run Tests
```
bundle install
bundle exec rake
```

## Build and Install
```
bundle exec rake gem:build
bundle exec rake gem:install
```

# Usage
# Config File
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

## Commands
```
Commands:
  gojira booktime [KEY] [TIME]  # Book time to a ticket for current day
  gojira filltoday [--dryrun]   # Fills current day with daily tasks and bucket tasks
  gojira help [COMMAND]         # Describe available commands or one specific command
  gojira today                  # Print a summary of current day's booked tasks
```
