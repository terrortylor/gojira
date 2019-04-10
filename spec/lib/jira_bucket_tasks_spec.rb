require 'jira_bucket_tasks'
require 'jira_request'
require 'rspec'

describe JiraBucketTasks do
  let(:bucket_config) do
    [
      { 'name' => 'Bucket task 1', 'key' => 'KEY-999', 'weight' => 5 },
      { 'name' => 'Bucket task 2', 'key' => 'KEY-888', 'weight' => 10 }
    ]
  end
  let(:test_date) { '1/4/2019' }
  let(:jira_request_double) { double('JiraRequest') }
  let(:test_obj) { JiraBucketTasks.new(jira_request_double, test_date) }

  before do
    test_obj.populate_bucket_tasks bucket_config
  end

  context 'populate_bucket_tasks' do
    it 'Should populate bucket tasks' do
      expect(test_obj.bucket_tasks.size).to eq(2)
    end
  end

  context 'fill_day' do
    it 'Should book all time to max weighted Task' do
      test_obj.fill_day(1800)

      expect(test_obj.bucket_tasks[0].key).to eq('KEY-888')
      expect(test_obj.bucket_tasks[0].time).to eq(1800) # 900 (15m) * 2

      expect(test_obj.bucket_tasks[1].key).to eq('KEY-999')
      expect(test_obj.bucket_tasks[1].time).to eq(0)
    end

    it 'Should book time to all tasks if exactly enought' do
      test_obj.fill_day(13_500) # 900 (15m) * 15 (total weight of issues)

      expect(test_obj.bucket_tasks[0].key).to eq('KEY-888')
      expect(test_obj.bucket_tasks[0].time).to eq(9_000) # # 900 (15m) * 10

      expect(test_obj.bucket_tasks[1].key).to eq('KEY-999')
      expect(test_obj.bucket_tasks[1].time).to eq(4_500) # 900 (15m) * 5
    end

    it 'Should continue to book time to tickets until all used up' do
      test_obj.fill_day(18_000) # 900 (15m) * 20 (total weight of issues)

      expect(test_obj.bucket_tasks[0].key).to eq('KEY-888')
      expect(test_obj.bucket_tasks[0].time).to eq(13_500) # 900 (15m) * 10 + 900 (15m) * 5

      expect(test_obj.bucket_tasks[1].key).to eq('KEY-999')
      expect(test_obj.bucket_tasks[1].time).to eq(4_500) # 900 (15m) * 5
    end

    it 'Should book remaining time to given task if less than item weight' do
      test_obj.fill_day(15_300) # 900 (15m) * 17 (total weight of issues)

      expect(test_obj.bucket_tasks[0].key).to eq('KEY-888')
      expect(test_obj.bucket_tasks[0].time).to eq(10_800) # 900 (15m) * 10 + 900 (15m) * 2

      expect(test_obj.bucket_tasks[1].key).to eq('KEY-999')
      expect(test_obj.bucket_tasks[1].time).to eq(4_500) # 900 (15m) * 5
    end
  end
end
