require_relative 'helper'

module Gitomate


class TestTestHelper < Test::Unit::TestCase

include TidBits::Options::Configurable

RFact   = Facts::Git::Repo


# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown. Give it a default path that is sure not to exist,
# because if creation fails, it will be attempted to be deleted...
#
@@tmp    = 'asdfasdf'



def self.startup

	@@help  = TestHelper.new
	@@brute = TestAFact.new( RFact )

end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	@@tmp = @@help.tmpDir
	@@brute.client = self

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end



def test_cloneRepo

	results = @@help.repo( remote: false, name: 'test_cloneRepo' ) do |path, name, out|

		assert( File.exist?( path ), out.ai )

		out

	end

	# Check that all the commands that have been run have returned zero.
	#
	results.each do |result|

		# ap result[ :cmd ]

		assert_equal( 0, result[ :status ], results.ai )

	end


end


end # class TestTestHelper
end # module Gitomate
