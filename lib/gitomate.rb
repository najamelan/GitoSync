require 'pp'
require 'awesome_print'
require 'logger'
require 'net/ssh'
require 'rugged'
require 'byebug'
require 'English'
require 'etc'

require 'active_support'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/string/indent'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/numeric/bytes'
require 'active_support/core_ext/numeric/conversions'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/file/atomic'

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
