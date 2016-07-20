require_relative '../helper'

module Gitomate


class TestFact < Test::Unit::TestCase

include TidBits::Options::Configurable


@@help = TestHelper.new

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown.
#
@@tmp = nil



def self.startup



end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	@@count = Facts::Fact.count

end


def teardown

	@@tmp and @@tmp.exist? and @@tmp.rm_secure

end


def test_00FactCounter

	assert_equal( 0, Facts::Fact      .count - @@count )
	assert_equal( 0, Facts::PathExist .count )

	Facts::PathExist.new( path: '/tmp' )

	assert_equal( 1, Facts::Fact      .count - @@count )
	assert_equal( 1, Facts::PathExist .count )

end



# Make sure we don't create unnecessary dependencies.
#
def test_01NoDoubleDepends

	one   = Facts::Path.new( path: '/tmp', type: 'directory' )
	assert_equal( 2, Facts::Fact.count - @@count )

	two   = Facts::Path.new( path: '/tmp', type: 'directory', dependOn: one )
	assert_equal( 3, Facts::Fact.count - @@count )

	three = Facts::Path.new( path: '/tmp', type: 'directory', dependOn: two )
	assert_equal( 4, Facts::Fact.count - @@count )

	four = Facts::Path.new( path: '/tmp', type: 'directory' )
	assert_equal( 6, Facts::Fact.count - @@count )

end



# Make sure we don't create unnecessary dependencies.
#
def test_02FactPool

	one   = Facts::Path.new( path: '/tmp', type: 'directory' )
	assert_equal( 2, Facts::Fact.count - @@count )

	two   = Facts::Path.new( path: '/tmp', type: 'directory', factPool: one )
	assert_equal( 3, Facts::Fact.count - @@count )

end



# Make sure we don't create unnecessary dependencies.
#
def test_03Combine

	@@help.repo( 'test_00repo' ) do |path, name, out|

		one   = Facts::Git::Repo.new( path: path, remotes: [{ name: 'origin', url: '/tmpremote' }] )
		# assert_equal( 5, Facts::Fact.count - @@count )

		depends = one.depend
		msg     = depends.map { |dep| { klass: dep.class, param: dep.params }  }

		assert_equal( 2, depends.count, msg.ai )


		repoExist = depends[ 0 ]
		msg = repoExist.depend.map { |dep| { klass: dep.class, param: dep.params }  }

		assert_equal( 1, repoExist.depend.count, msg.ai )
		assert_instance_of( Facts::Git::RepoExist, repoExist, msg.ai )


		remote = depends[ 1 ]
		msg = remote.depend.map { |dep| { klass: dep.class, param: dep.params }  }

		assert_equal( 1, remote.depend.count, msg.ai )
		assert_instance_of( Facts::Git::Remote, remote, msg.ai )


		remoteExist = remote.depend[ 0 ]
		msg = remoteExist.depend.map { |dep| { klass: dep.class, param: dep.params }  }

		assert_equal( 1, remoteExist.depend.count, msg.ai )
		assert_instance_of( Facts::Git::RemoteExist, remoteExist, msg.ai )


		repoExist2 = remoteExist.depend[ 0 ]
		msg = repoExist2.depend.map { |dep| { klass: dep.class, param: dep.params.keys }  }

		assert_equal( 1, repoExist2.depend.count, msg.ai )
		assert_instance_of( Facts::Git::RepoExist, repoExist2, msg.ai )

		assert_equal( repoExist.object_id, remoteExist.depend[ 0 ].object_id, msg.ai )

	end

end






end # class TestFact
end # module Gitomate
