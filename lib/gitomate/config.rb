
module Gitomate

class Config

include TidBits::Options::Configurable

attr_reader :logger
attr_reader :installCfg

# initialize with an array of config files and a driver (yaml) or a hash
# get the options as a hash (defaults, userset, options)
# set an option
#
def initialize()

	@box       = Rush[ '/' ]
	@logger    = Logger.new( STDERR )

	@installCfg = YAML.load_file "#{File.dirname( __FILE__ )}/../../conf/install.yml"
	@defaults   = YAML.load_file "#{File.dirname( __FILE__ )}/../../conf/defaults.yml"

	@installCfg.deep_symbolize_keys!
	@configDir = @installCfg[ :configDir ]


	@userset = {}

	@box[ "#{@configDir}/*.yml" ].each do |file|

		h = YAML.load_file file.full_path
		h.is_a?( Hash ) && @userset.recursiveMerge!( h )

	end

	setupOptions @defaults, @userset

end



end # class Config
end # module gitomate
