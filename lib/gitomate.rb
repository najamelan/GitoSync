require 'pp'
require 'awesome_print'
require 'logger'
require 'net/ssh'
require 'rugged'
require 'byebug'

require_relative '../ext/git/lib/git'
require_relative 'tidbits/lib/tidbits'

Dir[ "#{File.dirname( __FILE__ )}/gitomate/**/*.rb" ].sort.each do |source|

	require_relative source

end

# AwesomePrint.defaults = {
# 	indent:          3,      # Indent using 4 spaces.
# 	raw:             false,   # Do not recursively format object instance variables.
# 	sort_keys:       true,  # Do not sort hash keys.
# 	new_hash_syntax: false,  # Use the JSON like syntax { foo: 'bar' }, when the key is a symbol
# 	limit:           false,  # Limit large output for arrays and hashes. Set to a boolean or integer.
# }
