# frozen_string_literal: true

RSpec.describe Solution::Structs::Session do
  subject(:session_class) { described_class }

  describe '#initialize' do
    subject(:session) { session_class.new(*args) }

    context 'without args' do
      let(:args) { [] }

      it do
        expect { session }.to raise_error(Dry::Struct::Error, /:user_id is missing in Hash input/)
      end
    end

    context 'with args' do
      let(:args) do
        [user_id: user_id, session_id: session_id, browser: browser, time: time, date: date]
      end

      context 'with `user_id` as Integer' do
        let(:user_id) { 0 }

        context 'with `session_id` as Integer' do
          let(:session_id) { 0 }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }
            let(:expected_browser) { 'INTERNET EXPLORER 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 1 }

                context 'with `date` as `Date`' do
                  let(:date) { Date.today }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /\(Date\) has invalid type for :date violates constraints/
                    )
                  end
                end

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    is_expected.to have_attributes(
                      user_id: user_id,
                      session_id: session_id,
                      browser: expected_browser,
                      time: time,
                      date: date
                    )
                  end
                end

                context 'with `date` as incorrect `String`' do
                  let(:date) { '2021-abc-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /"2021-abc-03" \(String\) has invalid type for :date violates constraints/
                    )
                  end
                end
              end

              context 'when `time` is equal to 0' do
                let(:time) { 0 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    is_expected.to have_attributes(
                      user_id: user_id,
                      session_id: session_id,
                      browser: expected_browser,
                      time: time,
                      date: date
                    )
                  end
                end
              end

              context 'when `time` is less than 0' do
                let(:time) { -1 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /-1 \(Integer\) has invalid type for :time violates constraints/
                    )
                  end
                end
              end
            end

            context 'with `time` as correct String' do
              let(:time) { '10' }

              context 'with `date` as correct `String`' do
                let(:date) { '2021-05-03' }

                it do
                  is_expected.to have_attributes(
                    user_id: user_id,
                    session_id: session_id,
                    browser: expected_browser,
                    time: 10,
                    date: date
                  )
                end
              end
            end

            context 'with `time` as incorrect String' do
              let(:time) { 'abc' }

              context 'with `date` as correct `String`' do
                let(:date) { '2021-05-03' }

                it do
                  expect { session }.to raise_error(
                    Dry::Struct::Error,
                    /"abc" \(String\) has invalid type for :time/
                  )
                end
              end
            end

            context 'with `time` as empty String' do
              let(:time) { '' }

              context 'with `date` as correct `String`' do
                let(:date) { '2021-05-03' }

                it do
                  expect { session }.to raise_error(
                    Dry::Struct::Error,
                    /"" \(String\) has invalid type for :time/
                  )
                end
              end
            end

            context 'with `time` as `nil`' do
              let(:time) { nil }

              context 'with `date` as correct `String`' do
                let(:date) { '2021-05-03' }

                it do
                  expect { session }.to raise_error(
                    Dry::Struct::Error,
                    /nil \(NilClass\) has invalid type for :time/
                  )
                end
              end
            end
          end
        end

        context 'with `session_id` as correct String' do
          let(:session_id) { '0' }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }
            let(:expected_browser) { 'INTERNET EXPLORER 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    is_expected.to have_attributes(
                      user_id: user_id,
                      session_id: 0,
                      browser: expected_browser,
                      time: time,
                      date: date
                    )
                  end
                end
              end
            end
          end
        end

        context 'with `session_id` as incorrect String' do
          let(:session_id) { 'abc' }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /"abc" \(String\) has invalid type for :session_id/
                    )
                  end
                end
              end
            end
          end
        end

        context 'with `session_id` as empty String' do
          let(:session_id) { '' }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /"" \(String\) has invalid type for :session_id/
                    )
                  end
                end
              end
            end
          end
        end

        context 'with `session_id` as `nil`' do
          let(:session_id) { nil }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /nil \(NilClass\) has invalid type for :session_id/
                    )
                  end
                end
              end
            end
          end
        end
      end

      context 'with `user_id` as correct String' do
        let(:user_id) { '0' }

        context 'with `session_id` as Integer' do
          let(:session_id) { 0 }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }
            let(:expected_browser) { 'INTERNET EXPLORER 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    is_expected.to have_attributes(
                      user_id: 0,
                      session_id: session_id,
                      browser: expected_browser,
                      time: time,
                      date: date
                    )
                  end
                end
              end
            end
          end
        end
      end

      context 'with `user_id` as incorrect String' do
        let(:user_id) { 'abc' }

        context 'with `session_id` as Integer' do
          let(:session_id) { 0 }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /"abc" \(String\) has invalid type for :user_id/
                    )
                  end
                end
              end
            end
          end
        end
      end

      context 'with `user_id` as empty String' do
        let(:user_id) { '' }

        context 'with `session_id` as Integer' do
          let(:session_id) { 0 }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /"" \(String\) has invalid type for :user_id/
                    )
                  end
                end
              end
            end
          end
        end
      end

      context 'with `user_id` as `nil`' do
        let(:user_id) { nil }

        context 'with `session_id` as Integer' do
          let(:session_id) { 0 }

          context 'with `browser` as String' do
            let(:browser) { 'Internet Explorer 11.2' }

            context 'with `time` as Integer' do
              context 'when `time` is greater than 0' do
                let(:time) { 10 }

                context 'with `date` as correct `String`' do
                  let(:date) { '2021-05-03' }

                  it do
                    expect { session }.to raise_error(
                      Dry::Struct::Error,
                      /nil \(NilClass\) has invalid type for :user_id/
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
