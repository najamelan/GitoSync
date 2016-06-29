require          'test/unit'
require_relative '../lib/gitomate'

module Gitomate

class TestThorfile < Test::Unit::TestCase



def test_installer

	assert( Dir.exists? '/etc/gitomate.d' )

	assert( File.symlink? '/usr/local/bin/gitomate' )

end


end # class TestThorfile
end # module Gitomate
