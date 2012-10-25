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
		if path == "/xbmcCmds/xbmcHttp"
			return xbmcHttp(query);
		end
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
		metadataUrl = URI(parts[0])
		metadata = Net::HTTP.get(metadataUrl)
		doc = REXML::Document.new(metadata)
		videoUri = doc.root.elements['MediaContainer/Video/Part'].attributes['key']
		print(videoUri)
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
