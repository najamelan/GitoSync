require_relative 'helper'

module Gitomate


class TestFactRepo < Test::Unit::TestCase

RFact   = Facts::Repo
@@help  = TestHelper.new
@@brute = TestAFact.new( Facts::Repo )

# Provide a tmp directory variable for the class. This should be created in
# setup and removed in teardown. Give it a default path that is sure not to exist,
# because if creation fails, it will be attempted to be deleted...
#
@@tmp    = 'asdfasdf'



def self.startup

	Facts::Fact.config = @@help.config

end

def self.shutdown

	# TidBits::Susu.su( user: 'root' )

end


def setup

	@@tmp = @@help.tmpDir
	@@brute.client = self

end


def teardown

	FileUtils.remove_entry_secure @@tmp

end



def check( fact, pass, out, result )

	assert( fact.analyzed           , out.ai )
	assert( fact.analyzePassed      , out.ai )

	assert( fact.checked            , out.ai )
	assert( fact.checkPassed == pass, out.ai )

	assert_equal( result, fact.result, out.ai )

end



# def test_cloneRepo

# 	results = @@help.repo( remote: false, name: 'test_cloneRepo' ) do |path, name, out|

# 		assert( File.exist?( path ), out.ai )

# 		out

# 	end

# 	# Check that all the commands that have been run have returned zero.
# 	#
# 	results.each do |result|

# 		# ap result[ :cmd ]

# 		assert_equal( 0, result[ :status ], results.ai )

# 	end


# end



def test_repo

	@@help.repo( remote: false, name: 'test_repo' ) do |path, name, out|

		@@brute.check( { path: path }, { clean: true, branch: 'master' }, out )



		# # Make it a submodule
		# #
		# @@help.repo( remote: false, name: 'test_repoSuper', subs: path ) do |pathS, nameS, outS, subPaths|

		# 	fact = RFact.new( quiet: q, path: pathS )

		# 	fact.check
		# 	check( fact, true, outS, { initialized: true } )


		# 	fact = RFact.new( quiet: q, path: pathS, initialized: false )

		# 	fact.check
		# 	check( fact, false, outS, { initialized: false } )


		# 	# Test the submodule
		# 	#
		# 	fact = RFact.new( quiet: q, path: subPaths.first )

		# 	fact.check
		# 	check( fact, true, outS, { initialized: true } )


		# 	fact = RFact.new( quiet: q, path: subPaths.first, initialized: false )

		# 	fact.check
		# 	check( fact, false, outS, { initialized: false } )

		# end

	end

end



# def test_workingDir

# 	q = @@help.quiet

# 	@@help.repo( remote: false, name: 'test_workingDir' ) do |path, name, out|


# 		fact = RFact.new( quiet: q, path: path, clean: true )

# 		fact.check
# 		check( fact, true, out, { initialized: true, clean: true } )


# 		fact = RFact.new( quiet: q, path: path, clean: false )

# 		fact.check
# 		check( fact, false, out, { initialized: true, clean: false } )


# 		@@help.pollute path


# 		fact = RFact.new( quiet: q, path: path, clean: true )

# 		fact.check
# 		check( fact, false, out, { initialized: true, clean: false } )


# 		fact = RFact.new( quiet: q, path: path, clean: false )

# 		fact.check
# 		check( fact, true, out, { initialized: true, clean: true } )


# 	end

# end


# def test_workingDirSubs

# 	q = @@help.quiet

# 	@@help.repo( remote: false, name: 'test_workingDirSubs' ) do |path, name, out|

# 		# Make it a submodule
# 		#
# 		@@help.repo( remote: false, name: 'test_workingDirSubsSuper', subs: path ) do |pathS, nameS, outS, subPaths|

# 			fact = RFact.new( quiet: q, path: pathS, clean: true )

# 			fact.check
# 			check( fact, true, outS, { initialized: true, clean: true } )


# 			fact = RFact.new( quiet: q, path: pathS, clean: false )

# 			fact.check
# 			check( fact, false, outS, { initialized: true, clean: false } )


# 			# Pollute submodule
# 			@@help.pollute subPaths.first


# 			fact = RFact.new( quiet: q, path: pathS, clean: true )

# 			fact.check
# 			check( fact, false, outS, { initialized: true, clean: false } )


# 			fact = RFact.new( quiet: q, path: pathS, clean: false )

# 			fact.check
# 			check( fact, true, outS, { initialized: true, clean: true } )


# 			# Test the submodule
# 			#
# 			fact = RFact.new( quiet: q, path: subPaths.first, clean: true )

# 			fact.check
# 			check( fact, false, outS, { initialized: true, clean: false } )


# 			fact = RFact.new( quiet: q, path: subPaths.first, clean: false )

# 			fact.check
# 			check( fact, true, outS, { initialized: true, clean: true } )

# 		end

# 	end

# end



# def test_branch

# 	q = @@help.quiet

# 	@@help.repo( remote: false, name: 'test_branch' ) do |path, name, out|

# 		fact = RFact.new( quiet: q, path: path, branch: 'master' )

# 		fact.check
# 		check( fact, true, out, { initialized: true, branch: true } )



# 		fact = RFact.new( quiet: q, path: path, branch: 'dev' )

# 		fact.check
# 		check( fact, false, out, { initialized: true, branch: false } )



# 		@@help.pollute path

# 		fact = RFact.new( quiet: q, path: path, branch: 'master', clean: false )

# 		fact.check
# 		check( fact, true, out, { initialized: true, branch: true, clean: true } )


# 		# Change branch

# 	end

# end

end # class TestFactRepo
end # module Gitomate
