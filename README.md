Remapper
========

This is example working with Amazon Elastic IP from Ruby SDK.

Installation
-----------

Copy *config.yml.sample* to *config.yml* and edit it with your values.

Usage
-----

     require 'remapper'
     remapper = Remapper.new
     remapper.remap

Or:

     remapper.remap_to(remapper.instances.shuffle.first)
     
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/miry/ec2_ip_remapper/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
