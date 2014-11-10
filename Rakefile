gem_version = File.read("VERSION").strip
gem_name = "delicious-cli"

task :build do
  system "gem build #{gem_name}.gemspec"
end
 
task :release => :build do
  system "gem push #{gem_name}-#{gem_version}.gem"
end

task :install => :build do
  system "gem install #{gem_name}-#{gem_version}.gem"
end

task :pry do
  system "pry --gem"
end
