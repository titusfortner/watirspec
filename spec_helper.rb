# encoding: utf-8
begin
  require "rubygems"
rescue LoadError
end

require "tmpdir"
require "sinatra/base"
require "#{File.dirname(__FILE__)}/lib/watirspec"
require "#{File.dirname(__FILE__)}/lib/implementation"
require "#{File.dirname(__FILE__)}/lib/server"
require "#{File.dirname(__FILE__)}/lib/runner"
require "#{File.dirname(__FILE__)}/lib/guards"
require "#{File.dirname(__FILE__)}/lib/silent_logger"

if __FILE__ == $0
  # this is needed in order to have a stable Server on Windows + MRI
  WatirSpec::Server.run!
else
  WatirSpec::Runner.execute_if_necessary
end

TIMING_EXCEPTIONS = { raise_unknown_object_exception: Watir::Exception::UnknownObjectException,
                      raise_no_matching_window_exception: Watir::Exception::NoMatchingWindowFoundException,
                      raise_unknown_frame_exception: Watir::Exception::UnknownFrameException }

TIMING_EXCEPTIONS.each do |matcher, exception|
  RSpec::Matchers.define matcher do |expected|
    match do |actual|
      original_timeout = Watir.default_timeout
      Watir.default_timeout = 0
      begin
        actual.call
        false
      rescue exception
        true
      ensure
        Watir.default_timeout = original_timeout
      end
    end

    failure_message_for_should do |actual|
      "expected #{exception} but nothing was raised"
    end

    def supports_block_expectations?
      true
    end
  end
end

OTHER_EXCEPTIONS = { raise_object_disabled_exception: Watir::Exception::ObjectDisabledException,
                     raise_missing_way_of_finding_object_exception: Watir::Exception::MissingWayOfFindingObjectException,
                     raise_unknown_row_exception: Watir::Exception::UnknownRowException,
                     raise_object_read_only_exception: Watir::Exception::ObjectReadOnlyException,
                     raise_unknown_cell_exception: Watir::Exception::UnknownCellException,
                     raise_no_value_found_exception: Watir::Exception::NoValueFoundException }

OTHER_EXCEPTIONS.each do |matcher, exception|
  RSpec::Matchers.define matcher do |expected|
    match do |actual|
      begin
        actual.call
        false
      rescue exception
        true
      end
    end

    failure_message_for_should do |actual|
      "expected #{exception} but nothing was raised"
    end

    def supports_block_expectations?
      true
    end
  end
end
