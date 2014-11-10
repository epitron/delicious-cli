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

  #
  # posts_all options:
  # (from: https://github.com/SciDevs/delicious-api/blob/master/api/posts.md#v1postsall)
  #
  # &tag_separator=comma (optional) - (Recommended) Returns tags separated by a comma, instead of a space character. A space separator is currently used by default to avoid breaking existing clients - these default may change in future API revisions.
  # &tag={TAG} (optional) — Filter by this tag.
  # &start={xx} (optional) — Start returning posts this many results into the set.
  # &results={xx} (optional) — Return up to this many results. By default, up to 1000 bookmarks are returned, and a maximum of 100000 bookmarks is supported via this API.
  # &fromdt={CCYY-MM-DDThh:mm:ssZ} (optional) — Filter for posts on this date or later.
  # &todt={CCYY-MM-DDThh:mm:ssZ} (optional) — Filter for posts on this date or earlier.
  # &meta=yes (optional) — Include change detection signatures on each item in a ‘meta’ attribute. Clients wishing to maintain a synchronized local store of bookmarks should retain the value of this attribute - its value will change when any significant field of the bookmark changes.
  #
  def self.posts_all(options={})
    options = {:results => 100000}.merge(options)

    result = get('/posts/all', :query=>options)
    begin
      [result["posts"]["post"]].flatten
    rescue
      []
    end
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
