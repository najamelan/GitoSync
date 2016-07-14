require_relative '../helper'

module Gitomate


class TestFactPath < Test::Unit::TestCase

include TidBits::Options::Configurable


RFact   = Facts::Path


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


def test_00Basics

	s = File.stat @@tmp

	@@brute.check( { path: @@tmp }, { type: 'directory', uid: s.uid, gid: s.gid, mode: s.mode, mtime: s.mtime }, { test: "test_00Basics: #{@@tmp}" }, { type: 'file' } )

end



end # class TestFactPath
end # module Gitomate
