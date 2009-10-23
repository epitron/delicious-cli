require 'delicious-cli/settings'
require 'delicious-cli/api'

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

def printflush(string)
  print string
  STDOUT.flush
end

#################################################################

class Database

  @@filename = configfile('delicious.marshal')
  @@posts = []
  
  def self.posts
    @@posts
  end
  
  def self.init!
    $log.debug "Loading database..."
    @@posts = Marshal.load(open(@@filename)) if File.exists? @@filename
    $log.debug "done."
  end
  
  def self.clear!
    File.delete @@filename if File.exists? @@filename
    @@posts = []
  end

  def self.save!
    open(@@filename, "w") do |f|
      f.write Marshal.dump(@@posts)
    end
  end

  def self.sync(all=false)
    all = true if @@posts.empty?
    
    if all
      printflush "  |_ Retrieving all links..."
      posts = Delicious.posts_all
    else
      printflush "  |_ Retrieving new links..."
      posts = Delicious.posts_since(most_recent_time)
    end      
    
    $log.debug "sync: got #{posts.size} posts"
    
    puts " (#{posts.size} links found)"
    
    if posts.size == 0
      puts
      return
    end      
    
    printflush "  |_ Processing links..."
    posts.each { |post| post["time_string"] = post["time"]; post["time"] = DateTime.parse(post["time_string"]) }
    @@posts += posts.sort_by { |post| post["time"] }    
    puts "done!"
    
    printflush "  |_ Saving database..."
    save!
    
    puts "done!"
    puts
  end
  
  def self.most_recent_time
    #@@posts.order(:time.desc).limit(1).first[:time]
    @@posts.last["time_string"]
  end
  
  def self.add(params)
    @@posts << params
  end
  
  def self.last(n)
    @@posts[-n..-1]
  end
  
  def self.find(words)

    finders = words.map{|word| /#{word}/i }
    fields = %w[extended description href tag]
    
    @@posts.select do |post|
      finders.all? do |finder|
        fields.any? do |field|
          post[field].match finder
        end
      end
    end
    
  end  
  
end
