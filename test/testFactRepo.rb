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

	Facts::Fact.config = @@helper.config


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

	results = @@helper.cleanRepoCopy( remote: false, name: 'test_cloneRepo' ) do |path, name, output|

		assert( File.exist?( path ), output.ai )

		output

	end

	# Check that all the commands that have been run have returned zero.
	#
	results.each do |result|

		# ap result[ :cmd ]

		assert_equal( 0, result[ :status ], results.ai )

	end


end



def test_cleanRepo

	@@helper.cleanRepoCopy( remote: false, name: 'test_cleanRepo' ) do |path, name, output|

		fact = Facts::Repo.new( path: path, workDirClean: true, branch: 'master' )
		fact.check

		assert( fact.analyzed     , output.ai )
		assert( fact.analyzePassed, output.ai )

		assert( fact.checked      , output.ai )
		assert( fact.checkPassed  , output.ai )


		fact = Facts::Repo.new( path: path, workDirClean: true, branch: 'dev' )
		fact.check

		assert( fact.analyzed     , output.ai )
		assert( fact.analyzePassed, output.ai )

		assert( fact.checked      , output.ai )
		assert( !fact.checkPassed , output.ai )

	end

end



def test_dirtyRepo

	@@helper.dirtyRepoCopy( remote: false, name: 'test_dirtyRepo' ) do |path, name, output|

		fact = Facts::Repo.new( path: path, workDirClean: false, branch: 'master' )
		fact.check

		assert( fact.analyzed     , output.ai )
		assert( fact.analyzePassed, output.ai )

		assert( fact.checked      , output.ai )
		assert( fact.checkPassed  , output.ai )


		fact = Facts::Repo.new( path: path, workDirClean: true )
		fact.check

		assert( fact.analyzed     , output.ai )
		assert( fact.analyzePassed, output.ai )

		assert( fact.checked      , output.ai )
		assert( !fact.checkPassed , output.ai )

	end

end

end # class TestFactRepo
end # module Gitomate
