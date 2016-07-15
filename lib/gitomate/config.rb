
module Gitomate

class Config


def initialize( profile, fromCmdLine = [], **opts )

	@profile = profile.to_sym

	@profile == :include and raise "FATAL: The profile cannot be called [include]. Include is the only reserved name."


	# get options from <installDir>/conf into defaults
	#
	@cfg = TidBits::Options::ConfigProfile.new( @profile, '../../conf'.relpath, fromCmdLine )

	@cfg.setup( self.class )
	setupOptions opts

	# Setup the defaults for all classes
	#
	setupDefaults @profile

end

protected

def setupDefaults profile

	@cfg.setup( Feedback                , :Feedback            )
	# @cfg.setup( Sync                  ,   :Sync                )

	@cfg.setup( Git::Repo               , :Git  , :Repo        )
	@cfg.setup( Git::Remote             , :Git  , :Remote      )
	@cfg.setup( Git::Branch             , :Git  , :Branch      )

	@cfg.setup( Facts::Fact             , :Facts, :Fact        )
	@cfg.setup( Facts::PathExist        , :Facts, :PathExist   )
	@cfg.setup( Facts::Path             , :Facts, :Path        )

	@cfg.setup( Facts::Git::RepoExist   , :Facts, :Git, :RepoExist   )
	@cfg.setup( Facts::Git::Repo        , :Facts, :Git, :Repo        )
	@cfg.setup( Facts::Git::RemoteExist , :Facts, :Git, :RemoteExist )
	@cfg.setup( Facts::Git::Remote      , :Facts, :Git, :Remote      )
	@cfg.setup( Facts::Git::BranchExist , :Facts, :Git, :BranchExist )
	@cfg.setup( Facts::Git::Branch      , :Facts, :Git, :Branch      )

	profile == :testing or return

	@cfg.setup( TestFactRepo      , :TestFactRepo      )
	@cfg.setup( TestFactPathExist , :TestFactPathExist )
	@cfg.setup( TestFactPath      , :TestFactPath      )
	@cfg.setup( TestAFact         , :TestAFact         )
	@cfg.setup( TestGitolite      , :TestGitolite      )
	@cfg.setup( TestTestHelper    , :TestTestHelper    )
	@cfg.setup( TestThorfile      , :TestThorfile      )

	@cfg.setup( Git::TestBranch   , :Git, :TestBranch  )

end


end # class  Config
end # module Gitomate
