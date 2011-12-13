require 'rubygems'
require 'yaml'
require 'aws-sdk'

class Remapper
  
  attr_reader :ec2, :public_ip, :instances
  
  def initialize
    @config = YAML.load(read_config)
    AWS.config(@config)
    @ec2 = AWS::EC2.new
    @instances = @config['instances'].map{|instance_id| @ec2.instances[instance_id] }
    @public_ip = @ec2.elastic_ips[@config['elastic_ip']]
  end
  
  def read_config
    File.read(File.join(File.dirname(__FILE__), "config.yml"))
  end

  def remap_to(instance)
    instance.associate_elastic_ip @public_ip
  end
  
  def remap
    instance_id = @public_ip.instance_id
    idx = @instances.index{|instance| instance.id == instance_id} || 0
    (@instances[idx+1] || @instances[0]).associate_elastic_ip @public_ip
  end
end