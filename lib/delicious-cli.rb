#!/usr/bin/env ruby

#################################################################

require "delicious-cli/log"

libs = %w[
  rubygems

  optparse
  optparse/time
  ostruct

  delicious-cli/blank
  delicious-cli/db
  delicious-cli/display
  delicious-cli/api
  delicious-cli/settings
]

libs.each do |lib|
  #$log.debug "loading #{lib}"
  require lib
end

#################################################################

def sync
  puts "* Synchronizing database..."
  Database.sync
end

def redownload
  puts "* Redownloading database..."
  Database.clear!
  Database.sync
end

def config(first_time = false)
  # prompt user and stuff
  puts "Delicious login info"
  puts "---------------------------"
  puts
  print "Username: "
  username = gets.strip
  print "Password: "
  password = gets.strip
  
  puts
  puts "User: #{username.inspect} | Pass: #{password.inspect}"
  print "Is this correct? [y/N] "
  answer = gets.strip
  if answer =~ /^[Yy]$/
    puts 
    
    puts "* Checking that login/password works..."
    Delicious.basic_auth(username, password)
    if Delicious.valid_auth?    
      puts "  |_ Login successful! Saving config..."
      Settings["username"] = username
      Settings["password"] = password
      Settings.save!

      sync if first_time
      
      puts "* Everything is ready. Search away!" 
    else
      puts "  |_ Login failed! (Please check your credentials or network.)"
    end
    puts
  else
    puts "Aborting..."
  end
end


#################################################################

def main

  # In it!
  
  Database.init!
  begin
    Settings.load!
  rescue Errno::ENOENT
    config(true)
    retry
  end
  
  Delicious.basic_auth(Settings["username"], Settings["password"])

  # Parse de opts
  
  ARGV.push("--help") if ARGV.empty?
  
  options = OpenStruct.new
  OptionParser.new do |opts|
    opts.banner = "Usage: delicious [options] <search query>"
    opts.separator " "
    opts.separator "Specific options:"
    
    opts.on("-c", "--config", "(Re)configure login info (set your delicious username/password)") do |opt|
      options.config = true
    end

    opts.on("-t", "--test-auth", "Test that authentication info works") do |opt|
      options.test_auth = true 
    end

    opts.on("-s", "--sync", "Synchronize links") do |opt|
      options.sync = true
    end
  
    opts.on("-r", "--redownload", "Erase database and redownload all links") do |opt|
      options.redownload = true
    end

    opts.on("-a", "--all", "Show all links.") do |opt|
      options.list = 0
    end

    opts.on("-l", "--list [num]", "List the last [num] links (default 5, 0 for all)") do |opt|
      if opt
        options.list = opt.to_i
      else
        options.list = 5
      end
    end

    opts.on("-j", "--json", "Output results as (pretty) JSON.") do |opt|
      options.json = true
    end
  
    opts.on("-d", "--debug", "Debug info") do |opt|
      options.debug = true
    end
  

    opts.separator " "
    opts.separator "Common options:"

    # No argument, shows at tail.  This will print an options summary.
    # Try it and see!
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      puts
      exit
    end

    opts.on("-v", "--version", "Version information") do |opt|
      versionfile = File.join(File.dirname(File.expand_path(__FILE__)), "..", "VERSION")
      versionstring = open(versionfile).read
      puts "delicious-cli v#{versionstring}"
      puts
    end
    
  end.parse!
  
  
  # Handle options

  $log.level = Logger::DEBUG if options.debug
   
  if options.test_auth
    puts "Logging in as '#{Settings["username"]}': #{Delicious.valid_auth? ? "success!" : "fail!"}"
  elsif options.config 
    config
  elsif options.redownload
    redownload
  elsif options.sync
    sync
  else
    
    # get posts
    if options.list
      posts = Database.last(options.list)
    else
      words = ARGV
      exit 1 unless words.size > 0
      posts = Database.find(words)
    end
    
    
    if options.json
      require 'json'
      puts JSON.pretty_generate(posts)
    else
      if words
        posts.each { |match| display(match, words) }
      else
        posts.each { |post| display(post) }
      end
    end
    
  end
  
end


if $0 == __FILE__
  main
end
