require 'ruby-growl'

class GrowlController
  def initialize(settings)
    @growl = Growl.new "127.0.0.1", "squawk", ["squawk Notification"]
    @settings = settings
  end
  
  def growl(title, text, image_url)
    @growl.notify "squawk Notification", title, text, 0, @settings.get('sticky') # sticky is broken. FCK!
    # status['user'][0]['profile_image_url'] has image url!
  end
end