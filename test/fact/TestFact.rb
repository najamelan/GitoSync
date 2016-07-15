require_relative '../helper'

module Gitomate


class TestFact < Test::Unit::TestCase

include TidBits::Options::Configurable


@@help = TestHelper.new

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown.
#
@@tmp = nil



def self.startup



end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	Facts::Fact.reset

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end


def test_00FactCounter

	@@tmp = @@help.tmpDir


	assert_equal( 0, Facts::Fact      .count )
	assert_equal( 0, Facts::PathExist .count )

	Facts::PathExist.new( path: @@tmp )

	assert_equal( 1, Facts::Fact      .count )
	assert_equal( 1, Facts::PathExist .count )

end






end # class TestFact
end # module Gitomate
