require 'date'

# Class to fill remaining time in day with bucket tasks
class JiraBucketTasks
  FIFTEEN_MIN_IN_SECS = 900
  BucketIssue = Struct.new(:name, :key, :weight, :time)
  attr_reader :bucket_tasks

  def initialize(jira_request, date)
    @jira_request = jira_request
    # Date received as d/m/Y so add time
    @date = "#{date}T12:00:00.000+0000"
    @bucket_tasks = []
  end

  def fill_day(time)
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
    sorted_issues.each do |item|
    end
  end

  def populate_bucket_tasks(bucket_tasks)
    bucket_tasks.each do |task|
      @bucket_tasks.push BucketIssue.new(task['name'], task['key'], task['weight'], 0)
    end
  end

  def print_bucket_summary
    puts "Total Bucket Tasks:\t#{@bucket_tasks.size}"
  end
end
