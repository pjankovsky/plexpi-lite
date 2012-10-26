require "uri"
require "net/http"
require "rexml/document"

class PlexCommand

	def initialize(session, player)
		@session = session
		@player = player
	end

	def handle()
		request = @session.gets
		path = getPath(request)
		query = getQuery(request)
		print("------------------\nNew Request\n------------------\n")
		print("PATH: ", path, "\n")
		print("QUERY: ", query, "\n")
		@session.print "HTTP/1.1 200/OK\r\nServer: PlexPi\r\n\r\n"
		if path == "/xbmcCmds/xbmcHttp"
			result = xbmcHttp(query);
		end

		@session.write(result)
		@session.write("\n")
		@session.close()
	end

	def xbmcHttp(query)
		command = query['command'].strip
		if not command =~ /^[a-zA-Z]*\(.*\)$/
			return false
		end
		func = command.gsub(/^([a-zA-Z]*)\(.*/, '\\1').strip
		parts = command.gsub(/^[a-zA-Z]*\((.*)\)/, '\\1').strip.split(';')
		return self.send(func, parts)
	end

	def PlayMedia(parts)
		uri = URI(parts[0])
		metadata = Net::HTTP.get(uri)
		doc = REXML::Document.new(metadata)
		videoPath = nil
		doc.elements.each('MediaContainer/Video/Media/Part') do |element|
			videoPath = element.attributes["key"]
		end
		if videoPath == nil
			return "Unable to find video file to play\n"
		end
		uri.path=videoPath
		return @player.play(uri)
	end

	def getQuery(request)
		query = nil
		if request =~ /GET .* HTTP.*/
			query = request.gsub(/GET [^\?]*\?*(.*) HTTP.*/, "\\1").strip
		end
		if query == nil
			return nil
		end
		parts = query.split('&')
		hash = Hash.new()
		parts.each {|part| 
			sparts = part.split('=')
			hash[sparts[0]]=URI.unescape(sparts[1])
		}
		query = hash
		return query
	end

	def getPath(request)
		path = nil
		if request =~ /GET .* HTTP.*/
			path = request.gsub(/GET ([^\?]*)\?*.* HTTP.*/, "\\1").strip
		end
		return path
	end

end
