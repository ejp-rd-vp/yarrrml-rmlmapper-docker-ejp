#!/usr/bin/env ruby

require 'sinatra'
require 'open3'

get '/:type' do
  begin
    `mkdir /mnt/data/triples`
  rescue StandardError
    warn "triples folder coiuldn't be created.  Might already exist"
  end
  type = params[:type]
  serialization = ENV['SERIALIZATION'] || 'nquads'
  # (nquads (default), trig, trix, jsonld, hdt, turtle)
  extension = 'rdf'
  case serialization
  when 'trig'
    extension = 'trig'
  when 'trix'
    extension = 'trix'
  when 'jsonld'
    extension = 'json'
  when 'hdt'
    extension = 'hdt'
  when 'nquads'
    extension = 'nq'
  when 'turtle'
    extension = 'ttl'
  end

  puts type.to_s
  # rml = "#{type}_rml.ttl"
  yarrrml = "/mnt/data/#{type}_yarrrml.yaml"
  # datafile = "#{type}.#{extension}"
  a, b, c = Open3.capture3("bash map.sh #{yarrrml} --outputfile /mnt/data/triples/#{type}.#{extension} --serialization #{serialization}")
  puts a, b, c
end
