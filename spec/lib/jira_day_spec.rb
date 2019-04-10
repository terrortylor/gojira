require 'jira_day'
require 'jira_request'
require 'rspec'

describe JiraDay do
  let(:test_date) { '01/04/2019' }
  let(:query_test_date) { '2019/04/01' }
  let(:jira_request_double) { double('JiraRequest') }
  let(:test_obj) { JiraDay.new(jira_request_double, test_date, 'alex.tylor@widget.com') }

  context 'initialize' do
    it 'Should raise exception when search not 200' do
      response_double = double('response', code: 404)
      allow(jira_request_double).to receive(:tickets_booked_time_to_day).with(query_test_date).and_return(response_double)

      expect { test_obj.calculate_missing_time }.to raise_error("Response not 200, can't calculate missing time")
    end
  end

  context 'calculate_missing_time' do
    it 'Should calculate incomplete day' do
      incomplete_day_data = File.read('spec/test_data/incomplete_day_2019_04_01.json')
      response_double = double('response', code: 200, body: incomplete_day_data)
      allow(jira_request_double).to receive(:tickets_booked_time_to_day).with(query_test_date).and_return(response_double)

      issue1 = File.read('spec/test_data/issue_2_worklog_2019_04_01.json')
      response_double = double('response', code: 200, body: issue1)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-01').and_return(response_double)

      issue2 = File.read('spec/test_data/issue_3_worklog_2019_04_01.json')
      response_double = double('response', code: 200, body: issue2)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-02').and_return(response_double)

      expect(JSON).to receive(:parse).with(incomplete_day_data).and_call_original
      expect(JSON).to receive(:parse).with(issue1).and_call_original
      expect(JSON).to receive(:parse).with(issue2).and_call_original
      expect(test_obj).to receive(:populate_issues).once.and_call_original
      expect(test_obj).to receive(:calculate_worklogs).twice.and_call_original

      test_obj.calculate_missing_time

      expect(test_obj.date).to eq(query_test_date) # Date is reversed for querying jira
      expect(test_obj.issues.size).to eq(2)
      expect(test_obj.total_seconds).to eq(3600) # 01:00:00
      expect(test_obj.missing_seconds).to eq(25_200) # 06:45:00
    end

    it 'Should calculate complete day' do
      complete_day_data = File.read('spec/test_data/complete_day_2019_04_01.json')
      response_double = double('response', code: 200, body: complete_day_data)
      allow(jira_request_double).to receive(:tickets_booked_time_to_day).with(query_test_date).and_return(response_double)

      issue1 = File.read('spec/test_data/issue_8_hour_2019_04_01.json')
      response_double = double('response', code: 200, body: issue1)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-03').and_return(response_double)
      expect(JSON).to receive(:parse).with(complete_day_data).and_call_original
      expect(JSON).to receive(:parse).with(issue1).and_call_original
      expect(test_obj).to receive(:populate_issues).once.and_call_original
      expect(test_obj).to receive(:calculate_worklogs).once.and_call_original

      test_obj.calculate_missing_time

      expect(test_obj.date).to eq(query_test_date) # Date is reversed for querying jira
      expect(test_obj.issues.size).to eq(1)
      expect(test_obj.total_seconds).to eq(28_800) # 08:00:00
      expect(test_obj.missing_seconds).to eq(0) # 00:00:00
    end

    it 'Should set missing time as 0 if less than 0' do
      complete_day_data = File.read('spec/test_data/complete_day_2019_04_01.json')
      response_double = double('response', code: 200, body: complete_day_data)
      allow(jira_request_double).to receive(:tickets_booked_time_to_day).with(query_test_date).and_return(response_double)

      issue1 = File.read('spec/test_data/issue_10_hour_2019_04_01.json')
      response_double = double('response', code: 200, body: issue1)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-03').and_return(response_double)
      expect(JSON).to receive(:parse).with(complete_day_data).and_call_original
      expect(JSON).to receive(:parse).with(issue1).and_call_original
      expect(test_obj).to receive(:populate_issues).once.and_call_original
      expect(test_obj).to receive(:calculate_worklogs).once.and_call_original

      test_obj.calculate_missing_time

      expect(test_obj.date).to eq(query_test_date) # Date is reversed for querying jira
      expect(test_obj.issues.size).to eq(1)
      expect(test_obj.total_seconds).to eq(36_000) # 08:00:00
      expect(test_obj.missing_seconds).to eq(0) # 00:00:00
    end
  end

  context 'request_issue' do
    it 'Should raise exception when not 200' do
      response_double = double('response', code: 404)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-01').and_return(response_double)

      expect { test_obj.request_issue_worklog('KEY-01') }.to raise_error("Response not 200, can't get issue: KEY-01")
    end

    it 'Should return json is 200' do
      response_double = double('response', code: 200, body: '{"test": "yeah"}')
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-01').and_return(response_double)

      expect(test_obj.request_issue_worklog('KEY-01')).to eq(JSON.parse('{"test": "yeah"}'))
    end
  end

  context 'seconds_to_time' do
    it 'Should return seconds in time format' do
      expect(test_obj.seconds_to_time(300)).to eq('00:05:00')
    end
  end

  context 'populate_issues' do
    it 'Should populate array of issue' do
      incomplete_day_data = File.read('spec/test_data/incomplete_day_2019_04_01.json')
      response_body = JSON.parse(incomplete_day_data)

      issue1 = File.read('spec/test_data/issue_2_worklog_2019_04_01.json')
      response_double = double('response', code: 200, body: issue1)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-01').and_return(response_double)

      issue2 = File.read('spec/test_data/issue_3_worklog_2019_04_01.json')
      response_double = double('response', code: 200, body: issue2)
      allow(jira_request_double).to receive(:get_issue_worklog).with('KEY-02').and_return(response_double)

      expect(test_obj).to receive(:request_issue_worklog).with('KEY-01').once.and_call_original
      expect(test_obj).to receive(:request_issue_worklog).with('KEY-02').once.and_call_original

      test_obj.populate_issues response_body

      expect(test_obj.issues.size).to eq(2)
      expect(test_obj.issues[0].key).to eq('KEY-01')
      expect(test_obj.issues[0].time_booked).to eq(900)
      expect(test_obj.issues[1].key).to eq('KEY-02')
      expect(test_obj.issues[1].time_booked).to eq(2700)
    end
  end

  context 'calculate_worklogs' do
    it 'Should calculate the correct worklog for an issue' do
      issue = File.read('spec/test_data/issue_2_worklog_2019_04_01.json')
      issue_body = JSON.parse(issue)

      expect(test_obj.calculate_worklogs(issue_body)).to eq(900)
    end
  end
end
