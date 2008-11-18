require 'time'
require 'yaml'

class Settings
  attr_reader :last_run, :config
  
  def initialize
    # load yaml
    config_dir = File.join(File.dirname(__FILE__), '..', 'config')
    yaml_file = File.join(config_dir, 'griffin.yml')
    unless File.exist?(yaml_file)
      puts "#{yaml_file} doesn't exist. please copy it from #{yaml_file}-example and add your settings."
      exit
    end

    @config = YAML.load(IO.read(yaml_file))['griffin']

    # find last_run value.
    @last_run_file = File.join(config_dir, 'last_run.yml')
    @last_run = begin
      YAML.load(IO.read(@last_run_file))
    rescue
      Time.now - 600 # default to 10 minutes ago if there is no last_run.yml or it can't be read.
    end
  end

  def get(*args)
    result = @config
    while arg = args.shift
      result = result[arg.to_s]
    end
    result
  end

  def last_run=(val)
    @last_run = val
    # save to file
    File.open(@last_run_file, 'w') do |f|
      f.write(val.to_yaml)
    end
  end
end