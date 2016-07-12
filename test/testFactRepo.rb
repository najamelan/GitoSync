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

		file, pOut = @@help.pollute path

		@@brute.check( { path: path }, { clean: false, head: 'master' }, out + pOut )

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
			file, pOut = @@help.pollute subPath

			@@brute.check( { path: pathS }, { clean: false, head: 'master' }, outS + out + subOut + pOut )


			# Test the submodule
			#
			@@brute.check( { path: subPath }, { clean: false, head: 'master' }, outS + out + subOut + pOut )

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



def test_04remotes

	@@help.repo( 'test_04remotes' ) do |path, name, out|

		remote, url, rOut = @@help.addRemote path

		branch = 'master'
		track  = "#{remote}/#{branch}"

		# rOut += @@help.track path, branch, track

		@@brute.check(

			{
				path: path,
				remotes:  [ { name: remote, url: url } ],
				branches: [ { name: branch, track: track, ahead?: false, behind?: false, diverged?: false } ]
			},

			{
				clean:    true,
				head:     'master',
			},

			out + rOut
		)

	end

end



def test_05diverged

	@@help.repo( 'test_05diverged' ) do |path, remoteName, out|

		remoteName, url, rOut = @@help.addRemote path

		path2, clOut = @@help.clone url

		file, cOut  = @@help.commitOne path2
		file, cOut2 = @@help.commitOne path

		pOut = @@help.push path2

		branch = 'master'
		track  = "#{remoteName}/#{branch}"

		out += rOut + clOut + cOut + cOut2 + pOut

		branchFact = Gitomate::Facts::Git::Branch.new(

			path:       path    ,
			name:       branch  ,
			track:      track   ,
			ahead?:     true    ,
			behind?:    true    ,
			diverged?:  true    ,
			ahead:      1       ,
			behind:     1       ,
			diverged: [1, 1]

		)

		branchFact.check


		assert( branchFact.analyzePassed  , out.ai )
		assert( branchFact.checkPassed    , out.ai )



		@@brute.check(

			{
				path:     path                                ,
				remotes:  [ { name: remoteName, url: url } ]  ,
				dependOn: branchFact

			},

			{
				clean:    true     ,
				head:     'master' ,
			},

			out
		)

		@@brute.check(

			{
				path: path2,
				remotes:  [ { name: remoteName, url: url } ],

				branches:
				[{
					name:       branch  ,
					track:      track   ,
					ahead?:     false   ,
					behind?:    false   ,
					diverged?:  false   ,
					ahead:      0       ,
					behind:     0       ,
					diverged: [0, 0]
				}]
			},

			{
				clean:    true,
				head:     'master',
			},

			out
		)

	end

end

end # class TestFactRepo
end # module Gitomate
