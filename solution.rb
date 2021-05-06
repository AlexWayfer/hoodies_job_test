# frozen_string_literal: true

require 'zlib'
require 'stringio'
require 'json'

require 'sorted_set'

require 'dry-struct'
require 'dry/monads'

module Solution
  ## Types of the project
  module Types
    include Dry.Types()

    DateString = Types::String.constrained(
      ## February 31 will pass :(
      format: /^[1-9]\d\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/
    )

    UpcasedString = Types::String.constructor(&:upcase)

    DataRowType = Types::String.enum('user', 'session')
  end

  module Structs
    ## These structs are used in meta-programming, so the order of attributes is important!

    ## User struct
    class User < Dry::Struct
      attribute :id, Types::Coercible::Integer
      attribute :first_name, Types::Strict::String
      attribute :last_name, Types::Strict::String
      attribute :age, Types::Coercible::Integer.constrained(gteq: 0)

      def full_name
        "#{first_name} #{last_name}"
      end
    end

    ## Session struct
    class Session < Dry::Struct
      attribute :user_id, Types::Coercible::Integer
      attribute :session_id, Types::Coercible::Integer
      attribute :browser, Types::UpcasedString
      attribute :time, Types::Coercible::Integer.constrained(gteq: 0)
      attribute :date, Types::DateString
    end
  end

  ## Custom class with User stats and data
  class UserStats
    attr_accessor :struct

    # attr_reader(
    #   :sessions_count, :total_time, :longest_session, :browsers,
    #   :used_ie, :always_used_chrome, :dates
    # )

    def initialize
      @struct = nil
      @sessions_count = 0
      @total_time = 0
      @longest_session = 0
      @browsers = []
      @used_ie = false
      @always_used_chrome = true
      @dates = SortedSet.new
    end

    IE_REGEXP = /INTERNET EXPLORER/.freeze
    CHROME_REGEXP = /CHROME/.freeze

    def add_session(session)
      @sessions_count += 1
      @total_time += session.time
      @longest_session = session.time if session.time > @longest_session
      @browsers << session.browser
      @used_ie ||= session.browser.match? IE_REGEXP
      @always_used_chrome &&= session.browser.match? CHROME_REGEXP
      @dates.add session.date
    end

    def to_json(*args)
      {
        sessionsCount: @sessions_count,
        totalTime: "#{@total_time} min.",
        longestSession: "#{@longest_session} min.",
        browsers: @browsers.sort!.join(', '),
        usedIE: @used_ie,
        ## `nil` if no browsers were used, so we can't say definitely
        alwaysUsedChrome: @browsers.any? ? @always_used_chrome : nil,
        dates: @dates.to_a.reverse!
      }.to_json(*args)
    end
  end

  ## Monad for archive reading
  class ReadArchive
    include Dry::Monads[:result]

    def call(file_name:)
      if File.exist? file_name
        ## Returns IO-like object
        Success Zlib::GzipReader.new StringIO.new File.read file_name
      else
        Failure :file_not_found
      end
    end
  end

  ## Monad for parsing single CSV line
  class ParseLine
    include Dry::Monads[:result]

    def call(line:)
      ## `CSV.parse_line` takes too much time
      data_row_values = line.split ','

      case data_row_values.first
      when 'user'
        Success initialize_user_struct data_row_values
      when 'session'
        Success initialize_session_struct data_row_values
      else
        Failure :unknown_line_type
      end
    end

    private

    def initialize_user_struct(values)
      Structs::User.new(
        id: values[1], first_name: values[2], last_name: values[3], age: values[4]
      )
    end

    def initialize_session_struct(values)
      Structs::Session.new(
        user_id: values[1], session_id: values[2],
        browser: values[3], time: values[4], date: values[5]
      )
    end
  end

  ## Monad for filling report with one data struct
  class FillReport
    include Dry::Monads[:result]

    def call(report:, data_struct:)
      case data_struct
      when Solution::Structs::User
        report[:users_stats][data_struct.id].struct = data_struct
      when Solution::Structs::Session
        report[:users_stats][data_struct.user_id].add_session data_struct
        report[:totalSessions] += 1
        report[:unique_browsers].add data_struct.browser
      end
    end
  end

  ## Monad for report finalization
  class FinalizeReport
    include Dry::Monads[:result]

    def call(report:)
      unique_browsers = report.delete(:unique_browsers)
      report[:uniqueBrowsersCount] = unique_browsers.size
      report[:allBrowsers] = unique_browsers.join(',')
      users_stats = report.delete(:users_stats)
      report[:totalUsers] = users_stats.size
      report[:usersStats] = users_stats.map do |_user_id, user_stats|
        [user_stats.struct.full_name, user_stats]
      end.to_h

      Success report
    end
  end

  ## Monad for generating an expected JSON report
  class GenerateReport
    include Dry::Monads[:result]

    def call(io:)
      report = initialize_empty_report

      ## `each` instead of `read` for partial unarchivating
      io.each.with_index do |line, index|
        ParseLine.new.call(line: line.chomp).bind do |data_struct|
          FillReport.new.call(report: report, data_struct: data_struct)
        end
        puts "Line ##{index} parsed..." if (index % 100_000).zero?
      end

      FinalizeReport.new.call(report: report)
    end

    private

    def initialize_empty_report
      {
        users_stats: Hash.new { |hash, key| hash[key] = Solution::UserStats.new },
        totalSessions: 0,
        unique_browsers: SortedSet.new
      }
    end
  end

  ## Monad for saving report
  class SaveReport
    include Dry::Monads[:result]

    def call(report:, result_file_name:)
      File.write result_file_name, "#{report.to_json}\n"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Solution::ReadArchive.new.call(file_name: 'data_large.txt.gz').bind do |io|
    puts 'Archive loaded...'
    Solution::GenerateReport.new.call(io: io).bind do |report|
      Solution::SaveReport.new.call report: report, result_file_name: 'result.json'
    end
  end
end
