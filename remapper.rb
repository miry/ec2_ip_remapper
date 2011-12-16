require 'rubygems'
require 'yaml'
require 'aws-sdk'

class Remapper
  
  attr_reader :ec2, :public_ip, :instances
  
  def initialize
    @config = YAML.load(read_config)
    AWS.config(@config)
    @ec2 = AWS::EC2.new
    
    @instances = init_instance
    @public_ip = @ec2.elastic_ips[@config['elastic_ip']]
  end

  def init_instance
    result = []
    result = availble_instances unless @config['instances'].empty?
    result = instances_by_tags if result.empty?
    result
  end
  
  def availble_instances
    @config['instances'].map{|instance_id| @ec2.instances[instance_id] }.reject{|instance|(instance.status != :running) rescue true}
  end
  
  def check_instances
    @ec2.instances.each do |instance|
      instance.status
    end
  end
  
  def instances_by_tags
    return nil if @config['tags'].empty?
    @config['tags'].map do |tag_name, tag_values|
      next if tag_values.nil?
      tag_values.map do |tag_value|
        @ec2.instances.tagged(tag_name).tagged_values("*#{tag_value}*").map{|i| i}
      end
    end.flatten.compact.uniq{|instance| instance.id}.reject{|instance| (instance.status != :running) rescue true}
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