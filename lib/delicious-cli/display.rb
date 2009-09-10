require 'date'
require 'colorize'

#################################################################
## Load the colorize gem, and define the "hilite" function
begin
  require 'rubygems'
  require 'colorize'
  # Colourized hilite...
  class String
    def hilite(words, color=:white)
      escaped_words = words.map { |word| Regexp.escape(word) }
      matcher = /(#{escaped_words.join('|')})/io

      chunks = self.to_s.split(matcher)
      chunks.map do |chunk|
        if chunk =~ matcher
          chunk.black.on_yellow
        else
          chunk.send(color)
        end
      end.join('')
    end
  end
rescue LoadError
  STDERR.puts "Note: You should install the 'colorize' gem for extra prettiness.\n"
  # Monochrome hilite does nothing...
  class String
    def hilite(words); self; end
  end
end

#################################################################

def formatdate(dt, width=11)
  time = "%l:%M%P"
  date = "%d %b %g"
  #dt.strftime("#{date} #{time}")
  result = dt.strftime(date)
  
  result.ljust(width).light_yellow
end


def display(post, query, indent_size=11)
  indent = " " * indent_size

  date   = formatdate(post["time"], indent_size)
  desc   = post["description"].hilite(query, :light_white)
  ext    = post["extended"].hilite(query, :white)
  url    = post["href"].hilite(query, :light_blue)
  tags   = post["tag"].hilite(query, :light_cyan)

  puts date + desc
  puts indent + ext if post["extended"].any?
  puts indent + url
  puts indent + "(".cyan + tags + ")".cyan
  puts
end
