
module Gitomate

class Config

include TidBits::Options::Configurable

@@instance = nil


def self.get

	@@instance || @@instance = self.new

end


private
def initialize()

	# Load the installer
	#
	@defaults   = YAML.load_file "#{File.dirname( __FILE__ )}/../../conf/defaults.yml"
	@installCfg = YAML.load_file "#{File.dirname( __FILE__ )}/../../conf/install.yml"

	@installCfg.deep_symbolize_keys!


	# Parse the user's config files
	#
	@box     = Rush[ '/' ]
	@userset = {}

	@box[ "#{@installCfg[ :configDir ]}/*.yml" ].each do |file|

		h = YAML.load_file file.full_path
		h.is_a?( Hash ) && @userset.recursiveMerge!( h )

	end


	# These can't be overridden, so they're not really defaults
	#
	@userset.recursiveMerge! @installCfg

	setupOptions @defaults, @userset

end

end # class  Config
end # module Gitomate
