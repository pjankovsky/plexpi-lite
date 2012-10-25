require "socket"
require "./PlexCommand"
require "./OMXPlayer"

class PlexServer

	def initialize()
		@player = OMXPlayer.new()
	end

	def listen(address, port)
		@server = TCPServer.new(address, port)
		loop do
			session = @server.accept
			Thread.start(session) do |session|
				PlexCommand.new(session, @player).handle()
			end
		end
	end

end
