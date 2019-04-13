require 'date'
require 'rainbow'

module Gojira
  # Class to fill remaining time in day with bucket tasks
  class JiraBucketTasks
    FIFTEEN_MIN_IN_SECS = 900
    BucketIssue = Struct.new(:name, :issue_key, :weight, :time)
    attr_reader :bucket_tasks

    def initialize(jira_request, date)
      @jira_request = jira_request
      # Date received as d/m/Y so add time
      @date = "#{date}T12:00:00.000+0000"
      @bucket_tasks = []
    end

    def compute_missing_time(time)
      available_time_units = time / FIFTEEN_MIN_IN_SECS
      sorted_issues = @bucket_tasks.sort! { |x| x.weight }

      while available_time_units > 0
        sorted_issues.each do |item|
          if available_time_units >= item.weight
            item.time += (item.weight * FIFTEEN_MIN_IN_SECS)
            available_time_units -= item.weight
          else
            item.time += (available_time_units * FIFTEEN_MIN_IN_SECS)
            available_time_units = 0
          end
        end
      end
    end

    def book_missing_time
      @bucket_tasks.each do |task|
        bookable_time = Time.at(task.time).utc.strftime('%Hh %Mm')
        @jira_request.book_time_to_issue(task['issue_key'], bookable_time, @date) if task.time > 0
      end
    end

    def populate_bucket_tasks(bucket_tasks)
      bucket_tasks.each do |task|
        @bucket_tasks.push BucketIssue.new(task['name'], task['issue_key'], task['weight'], 0)
      end
    end

    def print_bucket_summary
      if @bucket_tasks.any? { |x| x.time > 0 }
        puts Rainbow("\tApply time adjustments").red
        @bucket_tasks.each do |task|
          puts "\t#{task.issue_key}\t#{Time.at(task.time).utc.strftime('%H:%M:%S')}\t- #{task.name}"
        end
        puts
      else
        puts puts Rainbow("\tDay is fully booked").green
      end
    end
  end
end
