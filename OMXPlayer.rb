
class OMXPlayer

	def initialize(args=nil)
		@args = args
		@command = '/usr/bin/omxplayer -s %s %s'
		@paused = false
	end

	def play(uri)
		tryToStop()
		command = @command % [uri, @args]
		@process = IO.popen(command)
		print("Playing Video\nProcessID: #{@process.pid}\n")
		return "Playing"
	end

	def pause()
		@process.write('p')
		if @paused
			@paued = false
		else
			@paused = true
		end
	end

	def tryToStop()
		if not defined? @process
			return nil
		end
		if not @process.closed?
			stop()
		end
	end

	def stop()
		@process.write('q')
		@process.close()
		@paused = false
	end

end