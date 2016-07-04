module Gitomate

class CliLogFormat < Logger::Formatter

def call( severity, time, progname, msg )

	"%5s [%s] %s\n" % [ severity, progname, msg2str( msg.first ) ]

end


end # LogfileFormat
end # Gitomate


# format % [
#           time.utc.iso8601,
#           progname,
#           $$,
#           severity,
#           msg2str(msg).strip
#         ]
