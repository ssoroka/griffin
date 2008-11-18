class Tweet
  attr_accessor :name, :text, :profile_image_url, :created_at
  
  def initialize(attrs)
    attrs.each{|k,v|
      instance_variable_set("@#{k}", v)
    }
  end
end