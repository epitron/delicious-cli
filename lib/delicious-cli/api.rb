require 'httparty'
require 'delicious-cli/settings'

# Documentation:
#   http://delicious.com/help/api

class Delicious
  include HTTParty
  base_uri 'api.del.icio.us:443/v1'
  format :xml

  def self.posts_update
    result = get('/posts/update')
    if result["update"]
      result["update"]["time"]
    else
      nil
    end
  end

  def self.posts_all(options={})
    result = get('/posts/all', :query=>options)
    [result["posts"]["post"]].flatten  # ensure it's an array
  end
  
  def self.posts_since(time_string)
    $log.debug "Retrieving links newer than #{time_string}"
    results = posts_all(:fromdt=>time_string)
    results.select { |r| r["time"] != time_string }
  end

  def self.valid_auth?
    not posts_update.nil?
  end

end
