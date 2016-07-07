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



def check( pass:, fact:, output: [] )

	assert( fact.analyzed           , output.ai )
	assert( fact.analyzePassed      , output.ai )

	assert( fact.checked            , output.ai )
	assert( fact.checkPassed == pass, output.ai )

end



def test_cloneRepo

	results = @@helper.cleanRepo( remote: false, name: 'test_cloneRepo' ) do |path, name, output|

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

	@@helper.cleanRepo( remote: false, name: 'test_cleanRepo' ) do |path, name, output|

		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: true, branch: 'master' )

		fact.check
		check( fact: fact, pass: true, output: output )


		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: true, branch: 'dev' )

		fact.check
		check( fact: fact, pass: false, output: output )

	end

end



def test_workingDir

	@@helper.cleanRepo( remote: false, name: 'test_workingDir' ) do |path, name, output|


		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: true )

		fact.check
		check( fact: fact, pass: true, output: output )


		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: false )

		fact.check
		check( fact: fact, pass: false, output: output )


		@@helper.pollute path


		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: true )

		fact.check
		check( fact: fact, pass: false, output: output )


		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, workDirClean: false )

		fact.check
		check( fact: fact, pass: true, output: output )


	end

end



def test_branch

	@@helper.cleanRepo( remote: false, name: 'test_branch' ) do |path, name, output|

		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, branch: 'master' )

		fact.check
		check( fact: fact, pass: true, output: output )



		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, branch: 'dev' )

		fact.check
		check( fact: fact, pass: false, output: output )



		@@helper.pollute path

		fact = Facts::Repo.new( quiet: @@helper.quiet, path: path, branch: 'master' )

		fact.check
		check( fact: fact, pass: true, output: output )


		# Change branch

	end

end

end # class TestFactRepo
end # module Gitomate
