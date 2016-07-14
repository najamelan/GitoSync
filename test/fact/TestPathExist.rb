require_relative '../helper'

module Gitomate


class TestFactPathExist < Test::Unit::TestCase

include TidBits::Options::Configurable


RFact   = Facts::PathExist
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


def test_00ConfirmExistance

	f = RFact.new path: @@tmp

	assert( f.check                      )

	assert( f.analyzed                   )
	assert( f.analyzePassed              )

	assert( f.checked                    )
	assert( f.checkPassed                )

	assert( ! f.fixed                    )
	assert( ! f.fixPassed                )

	assert( f.state[ :exist ][ :found ]  )
	assert( f.state[ :exist ][ :passed ] )

end


def test_01ConfirmAbsense

	f = RFact.new path: "#{@@tmp}/test_01ConfirmAbsense"

	assert( ! f.check                      )

	assert(   f.analyzed                   )
	assert(   f.analyzePassed              )

	assert(   f.checked                    )
	assert( ! f.checkPassed                )

	assert( ! f.fixed                      )
	assert( ! f.fixPassed                  )

	assert( ! f.state[ :exist ][ :found ]  )
	assert( ! f.state[ :exist ][ :passed ] )

end


def test_02Update

	path = "#{@@tmp}/test_02Update"

	f = RFact.new path: path

	assert( ! f.check                      )
	assert(   f.analyzePassed              )
	assert( ! f.checkPassed                )
	assert( ! f.fixPassed                  )
	assert( ! f.state[ :exist ][ :found ]  )
	assert( ! f.state[ :exist ][ :passed ] )


	# Repeat without filesystem change
	#
	assert( ! f.check( true )              )
	assert(   f.analyzePassed              )
	assert( ! f.checkPassed                )
	assert( ! f.fixPassed                  )
	assert( ! f.state[ :exist ][ :found ]  )
	assert( ! f.state[ :exist ][ :passed ] )


	FileUtils.mkpath path

	assert(   f.check( true )              )
	assert(   f.analyzePassed              )
	assert(   f.checkPassed                )
	assert( ! f.fixPassed                )
	assert(   f.state[ :exist ][ :found ]  )
	assert(   f.state[ :exist ][ :passed ] )

end



def test_03Depend

	path = "#{@@tmp}/test_03Depend"

	f = RFact.new( path: @@tmp, dependOn: RFact.new( path: path ) )

	assert( ! f.check                      )
	assert( ! f.analyzePassed              )
	assert( ! f.checkPassed                )
	assert( ! f.fixPassed                  )
	assert( ! f.state[ :exist ][ :found ]  )
	assert( ! f.state[ :exist ][ :passed ] )


	FileUtils.mkpath path

	assert(   f.check( true )              )
	assert(   f.analyzePassed              )
	assert(   f.checkPassed                )
	assert( ! f.fixPassed                )
	assert(   f.state[ :exist ][ :found ]  )
	assert(   f.state[ :exist ][ :passed ] )

end



def test_04CreateDir

	path = "#{@@tmp}/test_04CreateDir"

	f = RFact.new( path: path, create: 'directory' )

	assert( f.fix                        )
	assert( f.fixed                      )
	assert( f.analyzePassed              )
	assert( f.checkPassed                )
	assert( f.fixPassed                  )
	assert( f.state[ :exist ][ :found ]  )
	assert( f.state[ :exist ][ :passed ] )

	assert( File.exist?     path )
	assert( File.directory? path )

end



def test_05CreateFile

	path = "#{@@tmp}/test_04CreateFile"

	f = RFact.new( path: path )

	assert( f.fix                        )
	assert( f.analyzePassed              )
	assert( f.checkPassed                )
	assert( f.fixPassed                  )
	assert( f.state[ :exist ][ :found ]  )
	assert( f.state[ :exist ][ :passed ] )
	assert( f.state[ :exist ][ :fixed  ] )

	assert( File.exist? path )
	assert( File.file?  path )

end




end # class TestFactPathExist
end # module Gitomate
