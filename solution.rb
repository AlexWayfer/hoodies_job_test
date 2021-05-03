# frozen_string_literal: true

require 'zlib'
require 'stringio'

require 'sorted_set'

require 'dry-struct'

module Solution
  ## Types of the project
  module Types
    include Dry.Types()

    Coercible::Date = Types.Constructor(::Date) do |value|
      value.is_a?(::Date) ? value : ::Date.parse(value)
    end
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
end

if $PROGRAM_NAME == __FILE__
  gzip = Zlib::GzipReader.new StringIO.new File.read 'data_large.txt.gz'

  unique_browsers = SortedSet.new

  ## `each` instead of `read` for partial reading
  gzip.each.with_index do |line, index|
    # ...
  end

  report = {
    totalUsers: users.size,
    uniqueBrowsersCount: unique_browsers.size,
    totalSessions: sessions.size,
    allBrowsers: unique_browsers.join(','),
    usersStats: []
  }

  File.write 'result.json', "#{report.to_json}\n"
end
