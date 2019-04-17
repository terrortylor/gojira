require 'yaml'

module Gojira
  # Configuration loading class
  class Config
    DEFAULT_CONFIG_FILE = '~/.gojira.yml'.freeze
    attr_reader :config

    def initialize(config_path = nil)
      file_path = File.expand_path(config_path || DEFAULT_CONFIG_FILE)
      config_file = File.read(file_path)
      @config = YAML.load(config_file)
    rescue
      raise "Issue loading config file: #{file_path}"
    end

    def jira_host
      @config['jira']['host']
    end

    def jira_username
      @config['jira']['username']
    end

    def jira_api_key
      @config['jira']['api_key']
    end

    def jira_bucket_tasks
      @config['jira']['bucket_tasks']
    end

    def jira_daily_tasks
      @config['jira']['daily_tasks']
    end
  end
end
