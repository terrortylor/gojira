require 'jira_request'
require 'rspec'

describe JiraRequest do
  context 'When valid credentials' do
    let(:test_obj) { JiraRequest.new('jira.com', 'user@widget.com', '123abc') }
    let(:auth_and_header) { { basic_auth: { password: '123abc', username: 'user@widget.com' }, headers: { Accept: 'application/json' } } }

    it 'Should create new JiraRequest object' do
      expect(test_obj).to be_instance_of(JiraRequest)
    end

    it 'Should return issue response data when get_issue called' do
      response_double = double('response')
      allow(response_double).to receive(:code).and_return(200)
      allow(response_double).to receive(:body).and_return('{}')
      allow(HTTParty).to receive(:get).with(
        'jira.com/rest/api/3/issue/TIC-123',
        auth_and_header
      ).and_return(response_double)

      response = test_obj.get_issue('TIC-123')

      expect(response.code).to eq 200
      expect(response.body).to eq '{}'
    end

    it 'Should return issue response data when tickets_worked_on_this_week called' do
      response_double = double('response')
      allow(response_double).to receive(:code).and_return(200)
      allow(response_double).to receive(:body).and_return('{}')
      query = { query: { jql: 'worklogDate > startofWeek() AND worklogAuthor = currentUser()' } }
      allow(HTTParty).to receive(:get).with(
        'jira.com/rest/api/3/search',
        auth_and_header.merge(query)
      ).and_return(response_double)

      response = test_obj.tickets_worked_on_this_week

      expect(response.code).to eq 200
      expect(response.body).to eq '{}'
    end

    it 'Should return issue response data when tickets_booked_time_today called' do
      response_double = double('response')
      allow(response_double).to receive(:code).and_return(200)
      allow(response_double).to receive(:body).and_return('{}')
      query = { query: { jql: "worklogDate = '2019/04/03' AND worklogAuthor = currentUser()" } }
      allow(HTTParty).to receive(:get).with(
        'jira.com/rest/api/3/search',
        auth_and_header.merge(query)
      ).and_return(response_double)

      response = test_obj.tickets_booked_time_to_day('2019/04/03')

      expect(response.code).to eq 200
      expect(response.body).to eq '{}'
    end
  end
end
