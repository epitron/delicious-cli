require 'logger'

$log = Logger.new(STDOUT)
$log.level = Logger::INFO
#$log.level = Logger::DEBUG

$log.datetime_format = "%d %b %g @ %l:%M:%S. %L %P "
