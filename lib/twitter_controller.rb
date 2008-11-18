require 'net/http'
require 'xmlsimple'

class TwitterController
  def initialize(settings)
    @settings = settings
  end
  
  def new_tweets(&block)
    xml = call_twitter(:friends_timeline)
    check_time = Time.now
    unless xml.nil?
      doc = XmlSimple.xml_in(xml) # returns a hash.  Maybe make this more sophisticated.
      if doc['error']
        puts doc['error']
      else
        doc['status'].each do |status|
          if status['user']

            tweet = Tweet.new(:name => status['user'][0]['name'].to_s, :text => status['text'].to_s,
              :created_at => Time.parse(status['created_at'].to_s),
              :profile_image_url => status['user'][0]['profile_image_url'])
          
            yield tweet if tweet.created_at > @settings.last_run
          end
        end
      end
      @settings.last_run = check_time
    end
  end
  
  def call_twitter(method, arg_options={})
    options = { :auth => true }.merge(arg_options)

    path    = "/statuses/#{method.to_s}.xml"
    headers = { "User-Agent" => @settings.get('twitter', 'username') }

    begin
      response = Net::HTTP.start('twitter.com', 80) do |http|
          req = Net::HTTP::Get.new(path, headers)
          req.basic_auth(@settings.get('twitter','username'), @settings.get('twitter', 'password')) if options[:auth]
          http.request(req)
      end

      response.body
    rescue Exception => e
      puts "Error talking to Twitter: #{e.class.name}: #{e.message}"
    end
  end
end