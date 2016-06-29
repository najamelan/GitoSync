require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'


Dir.entries( File.dirname( __FILE__ ) ).

	grep( /test.*\.rb/ ) { | file | require_relative file }



module Gitomate
class  TestSuite


def self.suite

	suite =  Test::Unit::TestSuite.new( "Gitomate Unit Tests" )

	suite << TestThorfile.suite

end



def self.run

	Test::Unit::UI::Console::TestRunner.run( self )

end


end # TestSuite
end # Gitomate
