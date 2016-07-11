require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

include TidBits::Options::Configurable


RFact   = Facts::Git::Repo
@@help  = TestHelper.new
@@brute = TestAFact.new( RFact )

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown. Give it a default path that is sure not to exist,
# because if creation fails, it will be attempted to be deleted...
#
@@tmp    = 'asdfasdf'



def self.startup



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


def test_00repo

	@@help.repo( 'test_00repo' ) do |pathS, nameS, outS|

		@@brute.check( { path: pathS }, { clean: true, head: 'master' }, outS )


		# Make it a submodule
		#
		@@help.repo( 'test_repoSub' ) do |path, name, out|

			subPath, subOut = @@help.addSubmodule pathS, path

			@@brute.check( { path: pathS }, { clean: true, head: 'master' }, outS + out + subOut )

			# Test the submodule
			#
			@@brute.check( { path: subPath }, { clean: true, head: 'master' }, outS + out + subOut )

		end

	end

end



def test_01workingDir

	@@help.repo( 'test_01workingDir' ) do |path, name, out|

		@@help.pollute path

		@@brute.check( { path: path }, { clean: false, head: 'master' }, out )

	end

end


def test_02workingDirSubs

	@@help.repo( 'test_02workingDirSubs' ) do |pathS, nameS, outS|

		# Make it a submodule
		#
		@@help.repo( 'test_02workingDirSubsSub' ) do |path, name, out|

			subPath, subOut = @@help.addSubmodule pathS, path

			# Pollute submodule
			#
			@@help.pollute subPath

			@@brute.check( { path: pathS }, { clean: false, head: 'master' }, outS + out + subOut )


			# Test the submodule
			#
			@@brute.check( { path: subPath }, { clean: false, head: 'master' }, outS + out + subOut )

		end

	end

end



def test_03head

	@@help.repo( 'test_03head' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, head: 'master' }, out, { head: 'dev' } )

		out += @@help.changeBranch path, 'dev'

		@@brute.check( { path: path }, { clean: true, head: 'dev' }, out, { head: 'master' } )

	end

end



# def test_04remotes

# 	@@help.repo( 'test_04remotes' ) do |path, name, out|

# 		name, url, rOut = @@help.addRemote path

# 		@@brute.check(

# 			{ path: path },

# 			{
# 				clean: true,
# 				head: 'master',
# 				remotes: [ { name: name, url: url } ]
# 			},

# 			out + rOut
# 		)

# 	end

# end

end # class TestFactRepo
end # module Gitomate
