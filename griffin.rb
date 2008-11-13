# Requires the following gems: xml-simple and ruby-growl (http://segment7.net/projects/ruby/growl/)

require 'rubygems'
require 'net/http'
require 'xmlsimple'
require 'ruby-growl'
require 'time'
require 'yaml'

$debug = true

$yaml_file = File.join(File.dirname(__FILE__), 'griffin.yml')
unless File.exist?($yaml_file)
  puts "#{$yaml_file} doesn't exist. please copy it from #{$yaml_file}-example and add your settings."
  exit
end

$config = YAML.load(IO.read($yaml_file))['griffin']

g = Growl.new "127.0.0.1", "squawk", ["squawk Notification"]
last_fetch = Time.now - 600 # last 10 minutes

puts "polling twitter for posts every #{$config['frequency']} minutes.."
puts "  Run me with & at the end to stick me in the background."

def call_twitter(method, arg_options={})
  options = { :auth => true }.merge(arg_options)

  path    = "/statuses/#{method.to_s}.xml"
  headers = { "User-Agent" => $config['twitter']['username'] }

  begin
    response = Net::HTTP.start('twitter.com', 80) do |http|
        req = Net::HTTP::Get.new(path, headers)
        req.basic_auth($config['twitter']['username'], $config['twitter']['password']) if options[:auth]
        http.request(req)
    end

    response.body
  rescue Exception => e
    puts "\n#{e.class.name}: #{e.message}"
  end
end

def debug(msg)
  if $debug
    STDOUT.printf msg
    STDOUT.flush
  end
end

while true do
  debug '.'
  xml = call_twitter(:friends_timeline)
  debug ','
  unless xml.nil?
    doc = YAML.load(XmlSimple.xml_in(xml).to_yaml)
    doc['status'].reverse.each do |status|
      debug '/'
      # debug status.inspect
      if status['user']
        if Time.parse(status['created_at'].to_s) > last_fetch
          debug '\\'
          g.notify "squawk Notification", status['user'][0]['name'].to_s, status['text'].to_s, 0, $config['sticky'] # sticky is broken. FCK!
          # status['user'][0]['profile_image_url'] has image url!
        end
      end
    end
  
    last_fetch = Time.now
  else
    debug '!'
  end
  debug 'z'
  sleep $config['frequency'] * 60
end