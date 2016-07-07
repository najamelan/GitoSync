require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

@@helper = TestHelper.new

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown. Give it a default path that is sure not to exist,
# because if creation fails, it will be attempted to be deleted...
#
@@tmp    = 'asdfasdf'


def self.startup

	@@helper.dropPrivs

end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	@@tmp = @@helper.tmpDir

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end


def test_cloneRepo

	@@helper.cleanRepo do |path, name|

		assert( File.exist? path )

	end
end

end # class TestFactRepo
end # module Gitomate
