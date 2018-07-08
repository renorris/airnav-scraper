#!/usr/bin/env ruby

require 'bigdecimal'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

require 'geo/coord'

# eg input: 32-37-53.240N
def parse_raw_coord_item(input)
	if input.match(/^(\d+)-(\d+)-(\d+\.\d+)([NEWS])$/)
		d = $1.to_i
		m = $2.to_i
		#s = BigDecimal.new($3)
		s = $3.to_f
		h = $4
		{
			d: d,
			m: m,
			s: s,
			h: h,
		}
	else
		raise "Unknown raw coord: #{input}"
	end
end

# eg input: 32-37-53.240N
def create_coord_from_raw(raw_lat, raw_lon)
  lat = parse_raw_coord_item(raw_lat)
  lon = parse_raw_coord_item(raw_lon)
	Geo::Coord.new(latd: lat[:d], latm: lat[:m], lats: lat[:s], lath: lat[:h], lngd: lon[:d], lngm: lon[:m], lngs: lon[:s], lngh: lon[:h])
end

input_fix = ARGV[0]

url = "http://www.airnav.com/airspace/fix/#{input_fix}"

page = Nokogiri::HTML(open(url))
# This is example of what we are looking for:
# <TD nowrap>32-37-53.240N  117-14-44.980W</TD>

td_no_wrap = page.css('td[nowrap]')
raw_location = td_no_wrap[0].text

items = raw_location.split(/\s+/)
raw_lat = items[0]
raw_lon = items[1]

coord = create_coord_from_raw(raw_lat, raw_lon)

# Example conversion:
# Input format: 32-37-53.240N  117-14-44.980W
# Decimal degress: 32.6314556, -117.24582777777778

decimal_degrees = coord.to_h
final_lat = "%.7f" % decimal_degrees[:lat]
final_lng = "%.7f" % decimal_degrees[:lng]

puts '{'
puts '    "Latitude": ' + final_lat + ','
puts '    "Name": ' + input_fix + ','
puts '    "Longitude": ' + final_lng
puts '},'

