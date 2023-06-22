#!/usr/bin/env ruby

require 'sinatra'
require 'open3'

get '/:type' do
    `mkdir /mnt/data/triples`
    type = params[:type]
    puts "#{type}"
    #rml = "#{type}_rml.ttl"
    yarrrml = "/mnt/data/#{type}_yarrrml.yaml"
    #datafile = "#{type}.#{extension}"
    a, b, c = Open3.capture3("bash map.sh #{yarrrml} --outputfile /mnt/data/triples/#{type}.ttl --serialization turtle")
    puts a,b,c


end
