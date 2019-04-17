require 'date'
require 'rainbow'

module Gojira
  # Class to check for daily tasks and book time as required
  class JiraDailyTasks
    DailyIssue = Struct.new(:name, :issue_key, :time, :booked)
    attr_reader :daily_tasks

    def initialize(jira_request, date)
      @jira_request = jira_request
      @date = "#{date}T12:00:00.000+0000"
      @daily_tasks = []
    end

    def populate_daily_tasks(daily_tasks, booked_tasks)
      raise 'daily_tasks is missing from config' if daily_tasks.nil?

      daily_tasks.each do |task|
        booked = booked_tasks.any? { |x| x.issue_key == task['issue_key'] }
        @daily_tasks.push DailyIssue.new(task['name'], task['issue_key'], task['time'], booked)
      end
    end

    def book_daily_tasks
      @daily_tasks.each do |task|
        bookable_time = task.time
        @jira_request.book_time_to_issue(task['issue_key'], bookable_time, @date) unless task.booked
        task.booked = true
      end
    end

    def print_summary
      puts Rainbow("\tDaily Tasks:").green
      @daily_tasks.each do |task|
        if task.booked
          puts Rainbow("\t\t#{task.issue_key}\t- #{task.name}").green
        else
          puts Rainbow("\t\t#{task.issue_key}\t- #{task.name} : #{task.time}").red
        end
      end
    end
  end
end
