# frozen_string_literal: true

require 'zlib'
require 'stringio'

require 'dry-struct'

module Types
  include Dry.Types()
end

class User < Dry::Struct
  attribute :id, Types::Coercible::Integer
  attribute :first_name, Types::Strict::String
  attribute :last_name, Types::Strict::String
  attribute :age, Types::Coercible::Integer.constrained(gteq: 0)
end

class Session < Dry::Struct
  attribute :user_id, Types::Coercible::Integer
  attribute :session_id, Types::Coercible::Integer
  attribute :time, Types::Coercible::Integer.constrained(gt: 1)
  attribute :date, Types::Coercible::Date
end

gzip = Zlib::GzipReader.new StringIO.new File.read 'data_large.txt.gz'

## `each` instead of `read` for partial reading
gzip.each.with_index do |line, index|
  # ...
end
