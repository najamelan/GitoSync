module Gitomate

class YamlLogFormat < Logger::Formatter

def call( severity, time, progname, msg )

	h = { 'severity ' => severity, 'time     ' => time.utc, 'component' => progname, 'message  ' => msg2str( msg.first ) }
	alignColons( YAML.dump( h ) )

end


private
def alignColons( msg )

	msg.gsub!( /^'/, '' )
	msg.gsub!( /':/ , ':' )

end





end # LogfileFormat
end # Gitomate


