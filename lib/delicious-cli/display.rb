require 'date'
require 'open3'

#################################################################
## Load the colorize gem, and define the "hilite" function
begin
  
  require 'delicious-cli/colored'
  
  # Colourized hilite...
  class String
    
    def hilite(words, color=:white)
      return self.send(color) if words.nil?
      
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
  
end


#################################################################

def term_width
  if `stty size` =~ /(\d+) (\d+)/
    return $2.to_i
  else
    return 80
  end
end

SCREEN_WIDTH = term_width

#################################################################

class String
  
  def wrap(width=80, chop=true)

    if (lines = self.split("\n")).size > 1
      return lines.map { |line| line.wrap(width, chop) }.flatten
    end
    
    lines = []
    left = 0
    
    loop do
      edge   = left + width - 1
      right  = self.rindex(/\s+|$/, edge)
      
      if right.nil? or right < left
        if chop
          right = edge
        else
          right = self.index(/\s+|$/, edge)
        end
      end
      
      line = self[left...right]
      lines << line.strip
      left = self.index(/[^\s]|$/, right)
      break if right >= (self.size-1)
    end
    
    lines
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


def display(post, query=nil, indent_size=11)
  indent    = " " * indent_size
  wrap_size = SCREEN_WIDTH - indent_size

  date         = formatdate(post["time"], indent_size)
  desc_lines   = post["description"].wrap(wrap_size).map { |line| line.hilite(query, :light_white) }
  url          = post["href"].hilite(query, :light_blue)
  tag_lines    = post["tag"].wrap(wrap_size-2).map { |line| line.hilite(query, :light_cyan) }

  if post["extended"].blank?
    ext_lines = []
  else
    ext_lines = post["extended"].wrap(wrap_size).map { |line| line.hilite(query, :white) }
  end
  
  # date / description
  puts date + desc_lines.first
  if desc_lines.size > 1
    desc_lines[1..-1].each { |line| puts indent + line }
  end
  
  # extended description
  ext_lines.each do |line|
    puts indent + line
  end  
  
  # url
  puts indent + url
  
  # tags
  print indent + "(".cyan + tag_lines.first
  if tag_lines.size > 1
    tag_lines[1..-1].each do |line|
      print "\n" + indent + " " + line
    end
  end
  puts ")".cyan
  
  puts
end
