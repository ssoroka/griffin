require 'rubygems'
require File.join(File.dirname(__FILE__), %w(.. lib), 'growl_controller')
require File.join(File.dirname(__FILE__), %w(.. lib), 'twitter_controller')
require File.join(File.dirname(__FILE__), %w(.. lib), 'tweet')
require File.join(File.dirname(__FILE__), %w(.. lib), 'settings')

class Griffin
  def initialize
    $debug = false

    @settings = Settings.new
    @growler = GrowlController.new(@settings)
    @tweet_reader = TwitterController.new(@settings)

    puts "polling twitter for posts every #{@settings.get('frequency')} minutes.."
    puts "  Run me with & at the end to stick me in the background."
    start
  end

  def start
    while true do
      @tweet_reader.new_tweets do |tweet|
        @growler.growl(tweet.name, tweet.text, tweet.profile_image_url)
      end
      sleep @settings.get('frequency') * 60
    end
  end
end
