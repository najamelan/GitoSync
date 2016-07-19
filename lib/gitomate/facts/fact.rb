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



attr_reader :depend, :analyzed, :checked, :fixed, :analyzePassed, :checkPassed, :fixPassed, :state, :args



def initialize( opts, **args )

	setupOptions( opts )

	@mustDepend = Array.eat( options.mustDepend )
	@depend     = Array.eat( options.dependOn   )

	@args       = args
	@log        = Feedback.get self.class.name

	setArgs args
	requireDepends

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

	@state         = createState

end



# create a state object from options, only setting expect
# TODO: inherit options?
#
def createState( opts = options )

	state = {}

	# Only take actual tests
	#
	opts.select { |opt| ! Fact.options.metas.include? opt.to_s }.each do | key, value |

		state[ key ] = { expect: value }

	end

	state

end



protected


def setArgs args

	args.each do |key, value|

		self.instance_variable_set "@#{key}", value

		self.class.class_eval { attr_accessor key }

	end

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

			warn "#{self.class.name}: Dependency #{dep.class.name} #{dep.args.ai} failed."
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

	result = dependUseless?( klass, args, **opts )  and  return result


	@depend.push klass.new( **args, **opts )

end



# Check in our dependency chain if a dependency that does exaclty this has already been
# depended on. This prevents useless creation of Facts that check the same things over
# and over again.
#
def dependUseless?( klass, params, **opts )

	found = @depend.find { |dep| dep.dependUseless?( klass, params, **opts ) } and return found


	if                                                  \
		                                                 \
		   	klass        ==  self.class                \
		   && params       ==  args                      \
			&& createState( opts ).subset?( createState ) \
                                                       \
   then

   	return self

	end


	false

end



def < other

	self.class == other.class or return nil

	   self.args == other.args                        \
	&& self.createState.subset?( other.createState )

end



def > other

	self.class == other.class or return nil

	   self.args == other.args                        \
	&& self.createState.superset?( other.createState )

end



def == other

	self.class == other.class or return nil

	   self.args        == other.args         \
	&& self.createState == other.createState  \

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
