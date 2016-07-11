require_relative 'helper'

module Gitomate


class TestGitolite < Test::Unit::TestCase

include TidBits::Options::Configurable


@@helper = TestHelper.new


def self.startup


end


def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def test_connection

	`ssh #{@@helper.host} info`

	assert_equal( 0, $CHILD_STATUS )

end


end # class TestGitolite
end # module Gitomate
