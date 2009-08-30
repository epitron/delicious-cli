require 'sequel'
require 'sequel/extensions/blank'

require 'delicious-cli/settings'
require 'delicious-cli/api'

#################################################################

$log.debug "Loading database..."
DB = Sequel.sqlite(configfile('delicious.db'))
$log.debug "done."

#################################################################

=begin
Sample record:

{
  "href"=>"http://guru.com/",
  "time"=>"2009-04-24T06:06:37Z",
  "hash"=>"80e9a5f0bccb7f9e9dfd2e309eabd7de",
  "tag"=>"jobs business freelance employment outsourcing exchanges networking",
  "meta"=>"485e955fe2937fbef85390623ad0984c",
  "description"=>"Guru.com",
  "extended"=>"Worldwide freelancer marketplace."
}
=end

#################################################################

class Database
  @@posts = DB[:posts]

  def self.init!
    create_posts! unless DB.table_exists?(:posts)
  end  

  def self.clear!
    DB.drop_table(:posts)
    create_posts!
  end

  def self.create_posts!
    DB.create_table :posts do
      primary_key :id
      
      string :href
      string :time
      string :tag
      string :description
      text :extended
      string :hash
      string :meta
      
      index :hash, {:unique=>true}
      index [:description, :extended, :tag]
    end
  end
  
  def self.sync(all=false)
    all = true if @@posts.empty?
    
    if all
      print "* Retrieving all links..."
      STDOUT.flush
      posts = Delicious.posts_all
    else
      print "* Retrieving new links..."
      STDOUT.flush
      posts = Delicious.posts_since(most_recent_time)
    end      
    
    $log.debug "sync: got #{posts.size} posts"
    
    puts " (#{posts.size} links found)"
    
    return if posts.empty?
    
    print "* Inserting links into database..."
    
    counter = 0
    for post in posts
      counter += 1
      begin
        add post
      rescue Sequel::DatabaseError => e
        $log.debug "error: #{e} adding #{post.inspect}"
      end
      
      if counter % 37 == 0
        print "."
        STDOUT.flush
      end
    end
    
    puts "done!"
  end
  
  def self.most_recent_time
    @@posts.order(:time.desc).limit(1).first[:time]
  end
  
  def self.add(params)
    @@posts << params
  end
  
  def self.find(words)
    sequel_query = @@posts
    for word in words
      pattern = "%#{word}%" 
      sequel_query = sequel_query.filter(:extended.like(pattern) | :description.like(pattern) | :tag.like(pattern))
    end
    sequel_query.order(:time)
  end
  
  
end
