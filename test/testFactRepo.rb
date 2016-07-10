require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

RFact   = Facts::Git::Repo
@@help  = TestHelper.new
@@brute = TestAFact.new( RFact )

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


def test_repo

	@@help.repo( remote: false, name: 'test_repo' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, head: 'master' }, out )


		# Make it a submodule
		#
		@@help.repo( remote: false, name: 'test_repoSuper', subs: path ) do |pathS, nameS, outS, subPaths|

			@@brute.check( { path: pathS }, { clean: true, head: 'master' }, outS )

			# Test the submodule
			#
			@@brute.check( { path: subPaths.first }, { clean: true, head: 'master' }, outS )

		end

	end

end



def test_workingDir

	@@help.repo( remote: false, name: 'test_workingDir' ) do |path, name, out|

		@@help.pollute path

		@@brute.check( { path: path }, { clean: false, head: 'master' }, out )

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

			@@brute.check( { path: pathS }, { clean: false, head: 'master' }, outS )


			# Test the submodule
			#
			@@brute.check( { path: subPaths.first }, { clean: false, head: 'master' }, outS )

		end

	end

end



def test_head

	@@help.repo( remote: false, name: 'test_branch' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, head: 'master' }, out, { head: 'dev' } )

		out += @@help.changeBranch path, 'dev'

		@@brute.check( { path: path }, { clean: true, head: 'dev' }, out, { head: 'master' } )

	end

end

end # class TestFactRepo
end # module Gitomate
