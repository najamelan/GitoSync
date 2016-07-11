
module Gitomate

class TestThorfile < Test::Unit::TestCase

include TidBits::Options::Configurable


def test_installer

	assert( Dir.exists? '/etc/gitomate.d' )

	assert( File.symlink? '/usr/local/bin/gitomate' )

end


end # class TestThorfile
end # module Gitomate
