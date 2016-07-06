require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'
require_relative '../lib/gitomate'


# Turn off test unit's auto runner for those using the gem
#
defined?( Test::Unit::AutoRunner ) and Test::Unit::AutoRunner.need_auto_run = false


Dir[ File.join( File.dirname( __FILE__ ), '*.rb' ) ].each do | file |

	require_relative file

end



module Gitomate
class  TestSuite


def self.suite

	suite =  Test::Unit::TestSuite.new( "Gitomate Unit Tests" )

	# suite << TestThorfile.suite
	suite << TestGitolite.suite

end



def self.run( thorObject )

	Test::Unit::UI::Console::TestRunner.run( self )

end


end # TestSuite
end # Gitomate
