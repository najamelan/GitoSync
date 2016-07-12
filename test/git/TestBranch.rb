# require_relative '../helper'

module Gitomate
module Git


class TestBranch < Test::Unit::TestCase

include TidBits::Options::Configurable


@@help  = TestHelper.new

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

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end



def test_01Initialize

	@@help.repo( 'test_01Initialize' ) do |path, repoName, out|

		r = Gitomate::Git::Repo.new path

		r.branches.each do |name, branch|

			assert_equal( name, branch.name       , out )
			assert_equal( nil , branch.upstream   , out )
			assert_equal( nil , branch.divergence , out )
			assert_equal( nil , branch.ahead      , out )
			assert_equal( nil , branch.behind     , out )
			assert_equal( nil , branch.diverged?  , out )
			assert_equal( nil , branch.ahead?     , out )
			assert_equal( nil , branch.behind?    , out )

		end

	end

end


def test_02Remote

	@@help.repo( 'test_02Remote' ) do |path, repoName, out|

		remote, url, rOut = @@help.addRemote path

		branch = 'master'
		track  = "#{remote}/#{branch}"

		r = Gitomate::Git::Repo.new path

		b = r.branches[ branch ]

		out += rOut

		assert_equal( branch, b.name             , out )
		assert_equal( track , b.upstreamName     , out )
		assert_equal( track , b.upstream.name    , out )
		assert_equal( [0,0] , b.divergence       , out )
		assert_equal( 0     , b.ahead            , out )
		assert_equal( 0     , b.behind           , out )
		assert_equal( false , b.diverged?        , out )
		assert_equal( false , b.ahead?           , out )
		assert_equal( false , b.behind?          , out )

	end

end


def test_03Ahead

	@@help.repo( 'test_03Ahead' ) do |path, repoName, out|

		remote, url, rOut = @@help.addRemote path

		file, cOut = @@help.commitOne path

		branch = 'master'
		track  = "#{remote}/#{branch}"

		r = Gitomate::Git::Repo.new path

		b = r.branches[ branch ]

		out += rOut + cOut

		assert_equal( branch, b.name             , out )
		assert_equal( track , b.upstreamName     , out )
		assert_equal( track , b.upstream.name    , out )
		assert_equal( [1,0] , b.divergence       , out )
		assert_equal( 1     , b.ahead            , out )
		assert_equal( 0     , b.behind           , out )
		assert_equal( false , b.diverged?        , out )
		assert_equal( true  , b.ahead?           , out )
		assert_equal( false , b.behind?          , out )

	end

end


def test_04Behind

	@@help.repo( 'test_04Behind' ) do |path, repoName, out|

		remoteName, url, rOut = @@help.addRemote path

		path2, clOut = @@help.clone url

		file, cOut = @@help.commitOne path2

		pOut = @@help.push path2

		branch = 'master'
		track  = "#{remoteName}/#{branch}"

		r = Gitomate::Git::Repo.new path

		b = r.branches[ branch ]

		out += rOut + clOut + cOut + pOut

		assert_equal( branch, b.name             , out )
		assert_equal( track , b.upstreamName     , out )
		assert_equal( track , b.upstream.name    , out )
		assert_equal( [0,1] , b.divergence       , out )
		assert_equal( 0     , b.ahead            , out )
		assert_equal( 1     , b.behind           , out )
		assert_equal( false , b.diverged?        , out )
		assert_equal( false , b.ahead?           , out )
		assert_equal( true  , b.behind?          , out )

	end

end


def test_05Diverged

	@@help.repo( 'test_05Diverged' ) do |path, repoName, out|

		remoteName, url, rOut = @@help.addRemote path

		path2, clOut = @@help.clone url

		file, cOut  = @@help.commitOne path2
		file, cOut2 = @@help.commitOne path

		pOut = @@help.push path2

		branch = 'master'
		track  = "#{remoteName}/#{branch}"

		r = Gitomate::Git::Repo.new path

		b = r.branches[ branch ]

		out += rOut + clOut + cOut + cOut2 + pOut

		assert_equal( branch, b.name             , out )
		assert_equal( track , b.upstreamName     , out )
		assert_equal( track , b.upstream.name    , out )
		assert_equal( [1,1] , b.divergence       , out )
		assert_equal( 1     , b.ahead            , out )
		assert_equal( 1     , b.behind           , out )
		assert_equal( true  , b.diverged?        , out )
		assert_equal( true  , b.ahead?           , out )
		assert_equal( true  , b.behind?          , out )

	end

end

end # class TestBranch
end # module Git
end # module Gitomate
