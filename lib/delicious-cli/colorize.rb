#
# Colorize String class extension.
#
class String
  
  #
  # Colors Hash
  #
  COLORS = {
    :black          => 0,
    :red            => 1,
    :green          => 2,
    :yellow         => 3,
    :blue           => 4,
    :magenta        => 5,
    :cyan           => 6,
    :white          => 7,
    :default        => 9,
    
    :light_black    => 10,
    :light_red      => 11,
    :light_green    => 12,
    :light_yellow   => 13,
    :light_blue     => 14,
    :light_magenta  => 15,
    :light_cyan     => 16,
    :light_white    => 17
  }

  #
  # Modes Hash
  #
  MODES = {
    :default        => 0, # Turn off all attributes
    #:bright        => 1, # Set bright mode
    :underline      => 4, # Set underline mode
    :blink          => 5, # Set blink mode
    :swap           => 7, # Exchange foreground and background colors
    :hide           => 8  # Hide text (foreground color would be the same as background)
  }
  
  protected
  
  #
  # Set color values in new string intance
  #
  def set_color_parameters( params )
    if (params.instance_of?(Hash))
      @color = params[:color]
      @background = params[:background]
      @mode = params[:mode]
      @uncolorized = params[:uncolorized]
      self
    else
      nil
    end
  end

  public

  #
  # Change color of string
  #
  # Examples:
  #
  #   puts "This is blue".colorize( :blue )
  #   puts "This is light blue".colorize( :light_blue )
  #   puts "This is also blue".colorize( :color => :blue )
  #   puts "This is blue with red background".colorize( :color => :light_blue, :background => :red )
  #   puts "This is blue with red background".colorize( :light_blue ).colorize( :background => :red )
  #   puts "This is blue text on red".blue.on_red
  #   puts "This is red on blue".colorize( :red ).on_blue
  #   puts "This is red on blue and underline".colorize( :red ).on_blue.underline
  #   puts "This is blue text on red".blue.on_red.blink
  #
  def colorize( params=nil )
    
    return self.tagged_colors unless params
    return self unless STDOUT.isatty

    begin
        require 'Win32/Console/ANSI' if PLATFORM =~ /win32/
    rescue LoadError
        raise 'You must gem install win32console to use color on Windows'
    end
    
    
    color_parameters = {}

    if (params.instance_of?(Hash))
      color_parameters[:color] = COLORS[params[:color]]
      color_parameters[:background] = COLORS[params[:background]]
      color_parameters[:mode] = MODES[params[:mode]]
    elsif (params.instance_of?(Symbol))
      color_parameters[:color] = COLORS[params]
    end
    
    color_parameters[:color] ||= @color || 9
    color_parameters[:background] ||= @background || 9
    color_parameters[:mode] ||= @mode || 0

    color_parameters[:uncolorized] ||= @uncolorized || self.dup
   
    # calculate bright mode
    color_parameters[:color] += 50 if color_parameters[:color] > 10

    color_parameters[:background] += 50 if color_parameters[:background] > 10

    return "\033[#{color_parameters[:mode]};#{color_parameters[:color]+30};#{color_parameters[:background]+40}m#{color_parameters[:uncolorized]}\033[0m".set_color_parameters( color_parameters )
  end

  
  #
  # Return uncolorized string
  #
  def uncolorize
    return @uncolorized || self
  end
  
  #
  # Return true if sting is colorized
  #
  def colorized?
    return !@uncolorized.nil?
  end

  #
  # Make some color and on_color methods
  #
  COLORS.each_key do | key |
    eval <<-"end_eval"
      def #{key.to_s}
        return self.colorize( :color => :#{key.to_s} )
      end
      def on_#{key.to_s}
        return self.colorize( :background => :#{key.to_s} )
      end
    end_eval
  end

  #
  # Methods for modes
  #
  MODES.each_key do | key |
    eval <<-"end_eval"
      def #{key.to_s}
        return self.colorize( :mode => :#{key.to_s} )
      end
    end_eval
  end

  class << self
    
    #
    # Return array of available modes used by colorize method
    #
    def modes
      keys = []
      MODES.each_key do | key |
        keys << key
      end
      keys
    end

    #
    # Return array of available colors used by colorize method
    #
    def colors
      keys = []
      COLORS.each_key do | key |
        keys << key
      end
      keys
    end 

    #
    # Display color matrix with color names.
    #
    def color_matrix( txt = "[X]" )
      size = String.colors.length
      String.colors.each do | color |
        String.colors.each do | back |
         print txt.colorize( :color => color, :background => back )
        end
        puts " < #{color}"
      end
      String.colors.reverse.each_with_index do | back, index |
        puts "#{"|".rjust(txt.length)*(size-index)} < #{back}"
      end 
    end
  end
  puts

  #
  # BBS-style numeric color codes.
  #
  BBS_COLOR_TABLE = {
    0   => :black,
    1   => :blue,
    2   => :green,
    3   => :cyan,
    4   => :red,
    5   => :magenta,
    6   => :yellow,
    7   => :white,
    8   => :light_black,
    9   => :light_blue,
    10  => :light_green,
    11  => :light_cyan,
    12  => :light_red,
    13  => :light_magenta,
    14  => :light_yellow,
    15  => :light_white,
  }

  #        
  def valid_color?(string)
    COLORS.include?(string.to_sym) or (string =~ /^\d+$/ and BBS_COLOR_TABLE.include?(string.to_i))
  end
  
  #
  # Colorize a string that has "color tags".
  #
  # Examples:
  #
  # Colors as words:
  #    puts "<light_yellow><light_white>*</light_white> Hey mom! I am <light_green>SO</light_green> colourized right now.</light_yellow>".colorize
  #
  # Numeric ANSI colors (from the BBS days):
  #    puts "<10><5>*</5> Hey mom! I am <9>SO</9> colourized right now.</10>".colorize
  #
  def tagged_colors
    stack = []

    # matchers for just the color part of the tag
    open_tag_re     = /<([\w\d_]+)>/
    close_tag_re    = /<\/([\w\d_]+)>/

    # split the string into tags and texts
    tokens          = self.split(/(<\/?[\w\d_]+>)/)
    tokens.delete_if { |token| token.size == 0 }
    
    result        = ""

    tokens.each do |token|
      
      if open_tag_re =~ token and valid_color?($1)

        stack.push $1

      elsif close_tag_re =~ token and valid_color?($1)

	# if this color is on the stack somwehere...
        if pos = stack.rindex($1)
          # close the tag by removing it from the stack
          stack.delete_at pos
        else
          raise "Error: tried to close an unopened color tag -- #{token}"
        end

      else

        color = (stack.last || "white")
        color = BBS_COLOR_TABLE[color.to_i] if color =~ /^\d+$/
        result << token.colorize(color.to_sym)
        
      end
      
    end
    
    result
  end  

end

