#!/usr/bin/env ruby

require 'sinatra'
require 'open3'
require 'csv'
require 'fileutils'


get '/:type' do
  begin
    FileUtils.mkdir_p('/mnt/data/triples')
  rescue StandardError
    warn "triples folder coiuldn't be created.  Might already exist"
  end
  begin
    FileUtils.mkdir_p('/mnt/data/tmp')
  rescue StandardError
    warn "tmp folder coiuldn't be created.  Might already exist"
  end
  `rm -rf /mnt/data/tmp/*`
  `rm -rf /mnt/data/triples/*`

  type = params[:type]
  # note that this routine will now ONLY work with nquads
  serialization = ENV['SERIALIZATION'] || 'nquads'
  abort "MUST USE NQUADS" unless serialization == 'nquads'
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
  yarrrml = "/mnt/data/#{type}_yarrrml.yaml"


  # Call the splitter with your input CSV file and desired number of lines per file
  input_csv_file = '/mnt/data/CARE.csv'
  FileUtils.cp(input_csv_file, "#{input_csv_file}_BAK")
  lines_per_file = 200
  split_csv(input_csv_file, lines_per_file)

  Dir.glob(File.join('/mnt/data/tmp', '*.csv')) do |file|
    # Copy the file to the destination folder
    destination_file = File.join('/mnt/data/', "CARE.csv")  # this will overwrite
    FileUtils.cp(file, destination_file)
  
    # Execute the operation on the copied file
    a, b, c = Open3.capture3("bash map.sh #{yarrrml} --outputfile /mnt/data/tmp/#{File.basename(file)}.#{extension} --serialization #{serialization}")
  
    puts "Copied and processed #{File.basename(file)}"
  end
  
  Dir.glob(File.join('/mnt/data/tmp', "*.#{extension}")) do |file|
    # Copy the file to the destination folder
    `cat #{file} >> /mnt/data/triples/CARE.nq`
  end
end


def split_csv(input_file, lines_per_file)
  # Open the input CSV file and read its rows
  file_count = 0
  CSV.open(input_file, 'r') do |csv|
    # Get the header from the first row
    header = csv.first

    # Initialize variables to track the file splitting
    row_count = 0
    output_file = nil
    csv_writer = nil

    # Iterate over each row in the CSV file
    csv.each do |row|
      # If it's the first row of a new file, create a new CSV writer
      if row_count % lines_per_file == 0
        output_file.close if output_file
        file_count += 1
        output_filename = "/mnt/data/tmp/#{File.basename(input_file, '.csv')}_part_#{file_count}.csv"
        output_file = File.open(output_filename, 'w')
        csv_writer = CSV.new(output_file)

        # Write the header to the new file
        csv_writer << header
      end

      # Write the current row to the current output file
      csv_writer << row
      row_count += 1
    end

    # Close the final output file
    output_file.close if output_file
  end

  warn "Finished splitting the file into #{file_count} files."
end


