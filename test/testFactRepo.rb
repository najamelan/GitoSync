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


def test_cloneRepo

	repo = 'gitomate/test/cleanRepo'

	puts @@helper.gitoCmd "create #{repo}"

	Dir.chdir @@tmp

	puts `git clone #{@@helper.host}:#{repo}`

	assert( File.exist? "#{@@tmp}/cleanRepo" )

ensure

	FileUtils.remove_entry_secure "#{@@tmp}/cleanRepo"

	puts @@helper.gitoCmd "D unlock #{repo}"
	puts @@helper.gitoCmd "D rm     #{repo}"


end


end # class TestFactRepo
end # module Gitomate
