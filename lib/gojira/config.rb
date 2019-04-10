require 'json'
require 'singleton'
require 'yaml'

module Gojira
  # Configuration management class
  class Config
    include Singleton
    DEFAULT_CONFIG_FILE = '~/.gojira.yml'.freeze
    attr_reader :config

    def initialize
      if @config.nil?
        file_path = File.expand_path(DEFAULT_CONFIG_FILE)
        config_file = File.read(file_path)
        raise "Issue opening config file: #{file_path}" if config_file.nil?

        @config = YAML.load(config_file)
      end
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
  end
end
