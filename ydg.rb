#!/usr/bin/env ruby

unless ARGV.length == 4
	puts "Error: Incorrect number of arguments."
	puts "Usage: " + $0 + " [artist] [song] [venue] [date]"
end

EXT=".dat" # Data file extension
BANDSDIR="./bands/"
BANDTAGSDIR="./bands/"
SONGSDIR="./songs/"
VENUESFILE="./venues" + EXT
TAGSFILE="./tags" + EXT

BAND=ARGV[0]
SONG=ARGV[1]
VENUE=ARGV[2]
DATE=ARGV[3]

$band_file = BAND.gsub(/[^a-zA-Z0-9]/, "").downcase
$band_text = File.read(BANDSDIR + $band_file + EXT) 

def getTags()
	# get band tags
	band_tags = File.read(BANDTAGSDIR + $band_file + ".tags" + EXT)
	
	# get general tags
	general_tags = File.read(TAGSFILE)

	# venue tags handled by getVenueInfo

	tags_list = band_tags
	tags_list+= ", " + SONG unless SONG==""
	tags_list+= ", " + general_tags
	if $venue_tags.nil?
		tags_list+=", " + VENUE unless VENUE==""
	else
		tags_list+= ", " + $venue_tags 
	end

	return tags_list
end

def getVenueInfo(venue)
	if venue==""
		raise "No venue info."
	else
	venue_info=open(VENUESFILE) { |f| f.grep(/^#{Regexp.escape(venue + "|")}/) }
	venue_info=venue_info[0].split("|")
	return venue_info[1], venue_info[2], venue_info[3]
	end
end


begin
	if SONG =~ /(.*cover)/
		original_artist = SONG.gsub(/.*\((.*)cover\)/, "\\1").gsub(/\s+$/,"")
		original_artist_file = original_artist.gsub(/\s+/, "").downcase
		song=SONG.gsub(/\(.*cover\)/, "").gsub(/[^a-zA-Z0-9]/, "").downcase
		song_text = File.read(SONGSDIR + original_artist_file + "." + song + EXT)
	else
		song = SONG.gsub(/[^a-zA-Z0-9]/, "").downcase
		song_text = File.read(SONGSDIR + $band_file + "." + song + EXT)
	end
rescue
	no_lyrics=true
end

begin
venue_name, venue_link, $venue_tags = getVenueInfo(VENUE.gsub(/[^a-zA-Z0-9]/, "").downcase)
	if venue_link==""
		no_venue_info=true
	end
rescue
	venue_name = VENUE
	no_venue_info=true
end

output=BAND + " performing"
output+=' "' + SONG + '"' unless SONG==""
output+=" at " + venue_name unless venue_name==""
output+= " " + DATE + "\n\n"

output+=$band_text
output+="\n\n" + VENUE + ": " + venue_link unless no_venue_info
output+="\n\nLyrics:\n" + song_text unless no_lyrics

puts output
puts "\nTags:\n" + getTags()
