module Gitomate
module Facts

class Fact

include TidBits::Options::Configurable

@@factCounter = 0


def self.reset

	@@factCounter = 0

end


def self.count

	@@factCounter

end


def self.class_configured cfgObj

	# Yaml can't have symbols as rvalues
	#
	[

		settings.default.params      ,
	   settings.default.metas       ,
	   settings.userset.params      ,
	   settings.userset.metas       ,
	   settings.runtime.params      ,
	   settings.runtime.metas       ,
	   options.params               ,
	   options.metas

	].each { |setting| setting and setting.map!( &:to_sym ) }

end



attr_reader :depend, :analyzed, :checked, :fixed, :analyzePassed, :checkPassed, :fixPassed, :state, :params



def initialize( **opts )

	setupOptions( opts )

	reset

	@@factCounter += 1

end



def reset

	@analyzed      = false
	@checked       = false
	@fixed         = false

	@analyzePassed = false
	@checkPassed   = false
	@fixPassed     = false

	@mustDepend    = Array.eat( options.mustDepend )
	@depend        = Array.eat( options.dependOn   )
	@metas         = Array.eat( options.metas      )
	@factPool      = Array.eat( options.factPool   )

	@log           = Feedback.get self.class.name

	@params        = createParams
	@state         = createState

	requireDepends

end



# create a state object from options, only setting expect
#
def createState( opts = options )

	state = {}

	# Only take actual tests
	#
	opts.

		select { |opt| ! options.metas .include? opt }.
	   select { |opt| ! options.params.include? opt }.

	   each do | key, value |

			state[ key ] = { expect: value }

	   end

	state

end



protected


def createParams

	params = {}

	options.params.each do |key|

		params[ key ] = options[ key ]
		instance_variable_set "@#{key}", params[ key ]

		self.class.class_eval { attr_accessor key }

	end

	params

end



def requireDepends

	@mustDepend.each do |depend|

		if @depend.none? { |dep| dep.class.name == depend }

			raise "#{self.class.name.inspect} must depend on at least one #{depend.inspect}."

		end

	end

end



def analyze( update = false )

	# We already did this step and not asked to update, nothing to do
	#
	@analyzed && !update  and  return 'return'


	# Dependencies fail, return failure
	#
	# we actually run check here and not analyze, because with dependencies
	# usually it doesn't make sense to analyze something if a dependency hasn't checked out.
	# eg. if a file must exist before we stat it, PathExist.analyze will pass when it doesn't exist,
	#     but PathExist.check won't. That's the whole point of having dependencies, so we don't
	#     try things on stuff that doesn't even exist.
	#
	if !checkDepends( update )

		@analyzed      = true
		@analyzePassed = false
		return           'return'

	end


	# Provisional
	#
	@analyzed      = true
	@analyzePassed = true

end



def check( update = false )

	# We already did this step and not asked to update, nothing to do
	#
	@checked   && !update  and  return 'return'


	# We should update or analyze hasn't been done, analyze
	#
	!@analyzed ||  update  and  analyze( update )


	# Dependencies fail or analyze fails, return failure
	#
	if !checkDepends( update )  ||  !@analyzePassed

		@checked     = true
		@checkPassed = false
		return         'return'

	end

	# Provisional
	#
	@checkPassed = true
	@checked     = true

end



def fix( update = false )

	# We already did this step and not asked to update, nothing to do
	#
	@fixed   && !update  and  return 'return'


	# We should update or check hasn't been done, check
	#
	!@checked ||  update  and  check( update )


	# Dependencies fail or check fails, return failure
	#
	if !checkDepends( update )

		@fixed     = true
		@fixPassed = false
		return       'return'

	end

	# Provisional
	#
	@fixPassed = true
	@fixed     = true

end



def checkDepends( update = false )

	@depend.each do | dep |

		update || !dep.checked  and  dep.check( update )

		if ! dep.checkPassed

			warn "#{self.class.name}: Dependency #{dep.class.name} #{dep.params.ai} failed."
			return false

		end

	end

	true

end



# Add a dependency to our fact. The dependency won't be added if we already
# depend on a fact of the same type who's options are a subset of the one
# we're told to add.
#
def dependOn( klass, args, **opts )

	opts = opts.to_settings

	result = recycleDepend?( :dep, [], klass, args, **opts )  and  return result

	if result = recycleDepend?( :pool, [], klass, args, **opts )

		result.equal?( self )  or  @depend.push result
		return result

	end

	opts.factPool = Array.eat( opts.factPool )
	opts.factPool += [self] + @depend
	@depend.push klass.new( **args, **opts )

	@depend.last

end



# type == :dep Check in our dependency chain if a dependency that is a superset of this has already been
# depended on. This prevents useless creation of Facts that check the same things over
# and over again.
#
# type == :pool Check in the pool of available facts to see whether there is one exactly like the
# depend we need. In this case we will depend on it.
#
def recycleDepend?( type, visited = [], klass, args, **opts )

	visited.include? object_id and return false
	visited.push object_id


	if type == :pool

		@factPool.each do |fact|

			f = fact.recycleDepend?( type, visited, klass, args, **opts ) and return f

		end

	end


	@depend.each do |fact|

		f = fact.recycleDepend?( type, visited, klass, args, **opts ) and return f

	end


	otherState = createState( self.class.settings.default.deep_merge( self.class.settings.userset ).deep_merge( opts ) )

	type == :pool  and  stateComp = otherState      ==  createState
	type == :dep   and  stateComp = otherState.subset?( createState )


	if                                     \
		                                    \
		   	klass      ==  self.class     \
		   && args       ==  params         \
			&& stateComp                     \
                                          \
   then

   	return self

	end

	false

end



def < other

	self.class == other.class or return nil

	   params == other.params                        \
	&& createState.subset?( other.createState )

end



def > other

	self.class == other.class or return nil

	   params == other.params                        \
	&& createState.superset?( other.createState )

end



def == other

		self.class  == other.class          \
	&& params      == other.params         \
	&& createState == other.createState

end



def expect key

	@state[ key ][ :expect ]

end



def found key

	@state[ key ][ :found ]

end



def passed key

	@state[ key ][ :passed ]

end



def _fixed key

	@state[ key ][ :fixed ]

end



def debug(   msg ) log( msg, lvl: :debug   ) end
def info(    msg ) log( msg, lvl: :info    ) end
def warn(    msg ) log( msg, lvl: :warn    ) end
def error(   msg ) log( msg, lvl: :error   ) end
def fatal(   msg ) log( msg, lvl: :fatal   ) end
def unknown( msg ) log( msg, lvl: :unknown ) end

def log( msg, lvl: :warn )

	options.quiet or @log.send lvl, msg

end


end # class  Fact
end # module Facts
end # module Gitomate
