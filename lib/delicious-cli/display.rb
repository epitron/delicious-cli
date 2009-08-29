require 'date'
require 'colorize'

#################################################################
## Load the colorize gem, and define the "hilite" function
begin
  require 'rubygems'
  require 'colorize'
  # Colourized hilite...
  class String
    def hilite(query, color=:white)
      query = Regexp.new( Regexp.escape(query), Regexp::IGNORECASE )
      self.to_s.send(color).gsub(/(.*)(#{query})(.*)/) { $1.send(color) + $2.black.on_yellow + $3.send(color)}
    end
  end
rescue LoadError
  STDERR.puts "Note: You should install the 'colorize' gem for extra prettiness.\n"
  # Monochrome hilite does nothing...
  class String
    def hilite(query); self; end
  end
end

#################################################################

def formatdate(date, width=11)
  dt = DateTime.parse(date)
  time = "%l:%M%P"
  date = "%d %b %g"
  #dt.strftime("#{date} #{time}")
  result = dt.strftime(date)
  
  result.ljust(width).light_yellow
end


def display(post, query, indent_size=11)
  indent = " " * indent_size

  date   = formatdate(post[:time], indent_size)
  desc   = post[:description].hilite(query, :light_white)
  ext    = post[:extended].hilite(query, :white)
  url    = post[:href].hilite(query, :light_blue)
  tags   = post[:tag].hilite(query, :light_cyan)

  puts date + desc
  puts indent + ext if post[:extended].any?
  puts indent + url
  puts indent + "(".cyan + tags + ")".cyan
  puts
end
