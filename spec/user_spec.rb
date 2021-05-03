# frozen_string_literal: true

RSpec.describe Solution::User do
  subject(:user_class) { described_class }

  describe '#initialize' do
    subject(:user) { user_class.new(*args) }

    context 'without args' do
      let(:args) { [] }

      it { expect { user }.to raise_error(Dry::Struct::Error, /:id is missing in Hash input/) }
    end

    context 'with args' do
      let(:args) { [id: id, first_name: first_name, last_name: last_name, age: age] }

      let(:first_name) { 'Alexander' }
      let(:last_name) { 'Popov' }

      context 'with `id` as Integer' do
        let(:id) { 0 }

        context 'with `age` as Integer' do
          context 'when `age` is greater than 0' do
            let(:age) { 10 }

            it do
              is_expected.to have_attributes(
                id: 0,
                first_name: first_name,
                last_name: last_name,
                age: age
              )
            end
          end

          context 'when `age` is equal to 0' do
            let(:age) { 0 }

            it do
              is_expected.to have_attributes(
                id: 0,
                first_name: first_name,
                last_name: last_name,
                age: age
              )
            end
          end

          context 'when `age` is less than 0' do
            let(:age) { -1 }

            it do
              expect { user }.to raise_error(
                Dry::Struct::Error,
                /#{age} \(Integer\) has invalid type for :age violates constraints/
              )
            end
          end
        end

        context 'with `age` as correct String' do
          context 'when `age` is greater than 0' do
            let(:age) { '10' }

            it do
              is_expected.to have_attributes(
                id: 0,
                first_name: first_name,
                last_name: last_name,
                age: 10
              )
            end
          end
        end

        context 'with `age` as incorrect String' do
          let(:age) { 'abc' }

          it do
            expect { user }.to raise_error(
              Dry::Struct::Error,
              /"abc" \(String\) has invalid type for :age/
            )
          end
        end

        context 'with `age` as empty String' do
          let(:age) { '' }

          it do
            expect { user }.to raise_error(
              Dry::Struct::Error,
              /"" \(String\) has invalid type for :age/
            )
          end
        end

        context 'with `age` as `nil`' do
          let(:age) { nil }

          it do
            expect { user }.to raise_error(
              Dry::Struct::Error,
              /nil \(NilClass\) has invalid type for :age/
            )
          end
        end
      end

      context 'with `id` as correct String' do
        let(:id) { '0' }

        context 'with `age` as Integer' do
          context 'when `age` is greater than 0' do
            let(:age) { 10 }

            it do
              is_expected.to have_attributes(
                id: 0,
                first_name: first_name,
                last_name: last_name,
                age: age
              )
            end
          end
        end
      end

      context 'with `id` as incorrect String' do
        let(:id) { 'abc' }

        context 'with `age` as Integer' do
          context 'when `age` is greater than 0' do
            let(:age) { 10 }

            it do
              expect { user }.to raise_error(
                Dry::Struct::Error,
                /"abc" \(String\) has invalid type for :id/
              )
            end
          end
        end
      end

      context 'with `id` as empty String' do
        let(:id) { '' }

        context 'with `age` as Integer' do
          context 'when `age` is greater than 0' do
            let(:age) { 10 }

            it do
              expect { user }.to raise_error(
                Dry::Struct::Error,
                /"" \(String\) has invalid type for :id/
              )
            end
          end
        end
      end

      context 'with `id` as `nil`' do
        let(:id) { nil }

        context 'with `age` as Integer' do
          context 'when `age` is greater than 0' do
            let(:age) { 10 }

            it do
              expect { user }.to raise_error(
                Dry::Struct::Error,
                /nil \(NilClass\) has invalid type for :id/
              )
            end
          end
        end
      end
    end
  end
end
