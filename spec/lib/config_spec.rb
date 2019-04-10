require 'gojira/config'
require 'rspec'

describe Gojira::Config do
  context "file doesn't exist" do
    it "Should raise an error if file doesn't exist" do
      allow(File).to receive(:expand_path).with('~/.gojira.yml').and_return('/users/user/.gojira.yml')
      allow(File).to receive(:read).with('/users/user/.gojira.yml').and_return(nil)
      expect { Gojira::Config.instance }.to raise_error('Issue opening config file: /users/user/.gojira.yml')
    end
  end

  context 'file exists' do
    before do
      test_config = File.expand_path('spec/test_data/config.yml')
      allow(File).to receive(:expand_path).with('~/.gojira.yml').and_return(test_config)
    end

    it 'Should return YML object with configuration in' do
      config = Gojira::Config.instance.config

      expect(config['jira']['host']).to eq('https://jira.com')
      expect(config['jira']['username']).to eq('user@widget.com')
      expect(config['jira']['api_key']).to eq('123abc')
    end

    it 'Should return correct values with specific get methods' do
      config = Gojira::Config.instance

      expect(config.jira_host).to eq('https://jira.com')
      expect(config.jira_username).to eq('user@widget.com')
      expect(config.jira_api_key).to eq('123abc')
    end
  end
end
