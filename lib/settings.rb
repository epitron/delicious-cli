require 'fileutils'
require 'yaml'

require 'log'

#################################################################
HOMEDIR    = File.expand_path("~")
CONFIGDIR  = File.join(HOMEDIR, ".delicious")
#################################################################

#################################################################
class FileNotFound < IOError; end
#################################################################

#################################################################
def configfile(filename, check=false)
  path = File.join(CONFIGDIR, filename)
  
  if check and not File.exists? path
    raise FileNotFound, path
  end
  
  path
end
#################################################################



#################################################################

unless File.exists? CONFIGDIR
  $log.info "* Creating new config directory: #{CONFIGDIR}"
  FileUtils.mkdir_p CONFIGDIR 
end

class Settings
  
  def self.settings
    @settings ||= {}
  end
  
  def self.[](key)
    settings[key]
  end
  
  def self.[]=(key, val)
    settings[key] = val
  end  
  
  def self.load!
    @settings = YAML::load_file( configfile('settings.yml') )
  end

  def self.save!
    open( configfile('settings.yml'), "w" ) do |f|
      f.write YAML::dump(settings)
    end
  end
  
end
