# frozen_string_literal: true

require 'zlib'
require 'stringio'

gzip = Zlib::GzipReader.new StringIO.new File.read 'data_large.txt.gz'

## `each` instead of `read` for partial reading
gzip.each.with_index do |line, index|
  # ...
end
