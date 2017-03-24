#!/usr/bin/env ruby
# encoding: UTF-8

require 'json'

output = JSON.parse(`terraform output -json`)

mirror_private_name = output["mirror_public_name"]["value"]

single_instances = output
  .map do |name, value|
    if name =~ /aws_(.*)_private_name$/
      { symbolic_name: $1, private_name: value["value"] }
    end
  end
  .compact

multiple_instances = output
  .map do |name, value|
    if name =~ /aws_(.*)_private_names$/
      value["value"].each_with_index.map do |name, index|
        { symbolic_name: "#{$1}-#{index}", private_name: name }
      end
    end
  end
  .compact
  .flatten

instances = single_instances + multiple_instances
key_file = output["key_file"]["value"]

tunnel_string = <<~eos
# sumaform configuration start
Host mirror
  HostName #{mirror_private_name}
  StrictHostKeyChecking no
  User root
  IdentityFile #{key_file}
  ServerAliveInterval 120
eos

instances.each do |instance|
  tunnel_string += <<~eos
    Host #{instance[:symbolic_name]}
      HostName #{instance[:private_name]}
      StrictHostKeyChecking no
      User root
      IdentityFile #{key_file}
      ProxyCommand ssh root@mirror -W %h:%p
      ServerAliveInterval 120
  eos
  if instance[:symbolic_name] =~ /suma/
    tunnel_string += "  LocalForward 8043 127.0.0.1:443\n"
  end
end

tunnel_string += "# sumaform configuration end"

config_path = "#{Dir.home}/.ssh/config"
config_string = File.read(config_path)

if config_string =~ /(.*)^# sumaform configuration start$(.*)^# sumaform configuration end$(.*)/m
  File.write(config_path, "#{$1}#{tunnel_string}#{$3}")
else
  File.write(config_path, "#{config_string}\n#{tunnel_string}\n")
end
