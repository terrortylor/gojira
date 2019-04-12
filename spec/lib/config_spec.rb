require 'gojira/config'
require 'rspec'

describe Gojira::Config do
  context 'initialize' do
    it "Should raise an error if file doesn't exist" do
      allow(File).to receive(:expand_path).with('~/.gojira.yml').and_return('/users/user/.gojira.yml')
      allow(File).to receive(:read).with('/users/user/.gojira.yml').and_return(nil)
      expect { Gojira::Config.new }.to raise_error('Issue loading config file: /users/user/.gojira.yml')
    end

    it "Should raise an error if file doesn't exist when passed config file path" do
      allow(File).to receive(:expand_path).with('yabbadda.yml').and_return('yabbadda.yml')
      allow(File).to receive(:read).with('yabbadda.yml').and_return(nil)
      expect { Gojira::Config.new('yabbadda.yml') }.to raise_error('Issue loading config file: yabbadda.yml')
    end

    it 'Should return YML object with configuration in' do
      test_config = File.expand_path('spec/test_data/config.yml')
      allow(File).to receive(:expand_path).with('~/.gojira.yml').and_return(test_config)
      config = Gojira::Config.new

      expect(config.jira_host).to eq('https://jira.com')
      expect(config.jira_username).to eq('user@widget.com')
      expect(config.jira_api_key).to eq('123abc')
    end
  end
end
