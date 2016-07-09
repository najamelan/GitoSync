require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

RFact   = Facts::Repo
@@help  = TestHelper.new
@@brute = TestAFact.new( Facts::Repo )

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown. Give it a default path that is sure not to exist,
# because if creation fails, it will be attempted to be deleted...
#
@@tmp    = 'asdfasdf'



def self.startup

	Facts::Fact.config = @@help.config

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



def check( fact, pass, out, result )

	assert( fact.analyzed           , out.ai )
	assert( fact.analyzePassed      , out.ai )

	assert( fact.checked            , out.ai )
	assert( fact.checkPassed == pass, out.ai )

	assert_equal( result, fact.result, out.ai )

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



def test_repo

	@@help.repo( remote: false, name: 'test_repo' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, branch: 'master' }, out )


		# Make it a submodule
		#
		@@help.repo( remote: false, name: 'test_repoSuper', subs: path ) do |pathS, nameS, outS, subPaths|

			@@brute.check( { path: pathS }, { clean: true, branch: 'master' }, outS )

			# Test the submodule
			#
			@@brute.check( { path: subPaths.first }, { clean: true, branch: 'master' }, outS )

		end

	end

end



def test_workingDir

	@@help.repo( remote: false, name: 'test_workingDir' ) do |path, name, out|

		@@help.pollute path

		@@brute.check( { path: path }, { clean: false, branch: 'master' }, out )

	end

end


def test_workingDirSubs

	@@help.repo( remote: false, name: 'test_workingDirSubs' ) do |path, name, out|

		# Make it a submodule
		#
		@@help.repo( remote: false, name: 'test_workingDirSubsSuper', subs: path ) do |pathS, nameS, outS, subPaths|

			# Pollute submodule
			#
			@@help.pollute subPaths.first

			@@brute.check( { path: pathS }, { clean: false, branch: 'master' }, outS )


			# Test the submodule
			#
			@@brute.check( { path: subPaths.first }, { clean: false, branch: 'master' }, outS )

		end

	end

end



def test_branch

	@@help.repo( remote: false, name: 'test_branch' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, branch: 'master' }, out, { branch: 'dev' } )

		out += @@help.changeBranch path, 'dev'

		@@brute.check( { path: path }, { clean: true, branch: 'dev' }, out, { branch: 'master' } )

	end

end

end # class TestFactRepo
end # module Gitomate
