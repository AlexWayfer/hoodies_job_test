# frozen_string_literal: true

RSpec.describe Solution::SaveReport do
  describe 'result file content' do
    subject { File.read result_file_name }

    before do
      File.write result_file_name, ''

      described_class.new.call(report: report, result_file_name: result_file_name)
    end

    let(:report) do
      {
        total: 42,
        super: 'baz',
        users: {
          'Alex' => {
            age: 18,
            sessions: ['Chrome 2', 'Internet Explorer 9']
          },
          'Ivan' => {
            age: 56,
            sessions: ['Firefox 36', 'Chrome 8']
          }
        }
      }
    end

    let(:result_file_name) { 'result.json' }

    let(:expected_content) do
      <<~CONTENT
        {"total":42,"super":"baz","users":{"Alex":{"age":18,"sessions":["Chrome 2","Internet Explorer 9"]},"Ivan":{"age":56,"sessions":["Firefox 36","Chrome 8"]}}}
      CONTENT
    end

    it { is_expected.to eq expected_content }
  end
end
