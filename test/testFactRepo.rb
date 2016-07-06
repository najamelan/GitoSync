require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

@@helper = TestHelper.new
@@tmp    = ''


def self.startup

	@@helper.dropPrivs

end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	@@tmp = @@helper.tmpDir.first

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end


def test_connection



end


end # class TestFactRepo
end # module Gitomate
