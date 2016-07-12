
module Gitomate


class TestAFact

include TidBits::Options::Configurable

# The basic properties we are testing. This tells us this is not a test to be checked.
# eg. a file system path against which we test. Can be an array or an individual element.
#
attr_reader   :type
attr_accessor :client


def initialize( type, **opts )

	@type   = type

	setupOptions( opts )

end



# Will test the check part of the Fact. It will create Facts with the baseProp.
# If the requires condition is set and it's not met, the only thing that will be
# required from the Fact is to acknowledge this and to warn if other
# declarations about state are given.
#
# If requires aren't given, their default (passing) state is assumed. In this
# case all other declarations are tested in all possible combinations. Each time
# the complete state of the fact is checked to be correct.
#
# @param   state  The state of the entity the fact is to test. Specify everything you
#                 know about it, it will be tested feeding a fact all possible combinations
#                 of declarations.
#
# @param   msg    The error message to add to assertions.
#
# @return  void
#
# @example Usage:
#
#   class TestMyFact < Test::Unit::TestCase
#
#      @@brute = TestAFact.new( Facts::Path  )
#
#      def testPath
#
#         path = '/tmp/someDir'
#         FileUtils.mkpath path
#
#         # Note that exist: true will be assumed to be true and if it's not, all the other tests won't be run.
#         # You can test the fact with an unexisting path by passing exist: false here, and other tests won't
#         # be required, the fact will just be expected to warn if you pass other declarations that can't be checked.
#         #
#         @@brute.check( { path: path, type: :directory, empty: true } )
#
def check( baseProps, state, msg, failures = {} )


	# Make all possible combinations of the options we can send in.
	# Different options should be independent.
	#
	keys         = state.keys
	combinations = ( 0..keys.size ).flat_map{ |size| keys.combination( size ).to_a }


	combinations.each do |combo|

		query = {}

		combo.each do |key|

			query[ key ] = state[ key ]

		end

		debug = "#{msg.ai}\nCalled #{@type.ai} with: #{query.merge( baseProps ).ai}"

		fact  = @type.new( query.merge baseProps )


		baseProps.each do |key, prop|

			@client.assert_respond_to fact, key.to_sym

		end

		fact.check

		@client.assert( fact.analyzed     , debug + "\n#{fact.class.name.ai}" )
		@client.assert( fact.analyzePassed, debug + "\n#{fact.class.name.ai}" )

		@client.assert( fact.checked      , debug + "\n#{fact.class.name.ai}" )
		@client.assert( fact.checkPassed  , debug + "\n#{fact.class.name.ai}" )

		query.each do |key, value|

			@client.assert( fact.state[ key ][ :passed ], debug )

		end


	end


	# Test for things that should fail
	#
	combinations.each do |combo|

		query = {}

		combo.each do |key|

			query[ key ] = state[ key ]

		end

		query.each do |key, value|

			# if it's not a boolean, we're not interested for now
			# unless it's in the failures list
			#
			if !!value == value

				query[ key ] = !value

			elsif  failures.has_key?( key )

				query[ key ] = failures[ key ]

			else

				next

			end


			debug = "#{msg.ai}\nThe check should FAIL. Negated/changed key: #{key}.\nCalled #{@type.ai} with: #{query.merge( baseProps ).ai}"
			fact  = @type.new( query.merge baseProps )
			fact.check

			@client.assert(   fact.analyzed     , debug )
			@client.assert(   fact.analyzePassed, debug )

			@client.assert(   fact.checked      , debug )
			@client.assert( ! fact.checkPassed  , debug )

			@client.assert( ! fact.state[ key ][ :passed ], debug )

		end

	end

end

end # class TestAFact
end # module Gitomate
