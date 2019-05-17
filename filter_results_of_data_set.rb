require 'yaml'
require 'csv'
require 'set'

project_name = ARGV[0]

# Generate list of previously shared job ids
Dir.mkdir("#{project_name}/shared_reports") unless File.directory?("#{project_name}/shared_reports")
shared_report_file_names = Dir.entries("#{project_name}/shared_reports").select {|file| /csv/.match(file) }
shared_report_file_paths = shared_report_file_names.map {|name| "#{project_name}/shared_reports/#{name}"}
previously_shared_job_ids = Set.new
shared_report_file_paths.each do |file_path|
  CSV.foreach(file_path, headers: true) do |row|
    job_id = row[:job_id]
    job_id = row['job_id'] if job_id.nil? # older data sets using string as key
    previously_shared_job_ids << job_id
  end
end

pulled_data_file_names = Dir.entries("#{project_name}/pulled_data").select {|file| /yml/.match(file) }
pulled_data_file_paths = pulled_data_file_names.map {|name| "#{project_name}/pulled_data/#{name}"}

File.open("#{project_name}/blacklist.yml", 'w') {|f| f.puts [/mortician/].to_yaml} unless File.exist?("#{project_name}/blacklist.yml")
blacklisted_regex = YAML.load_file("#{project_name}/blacklist.yml")
# whitelisted actions commented out
# whitelisted_regex = YAML.load_file("#{project_name}/whitelist.yml")

filtered_job_data = {}
pulled_data_file_paths.each do |file_path|
  jobs_data = YAML.load_file(file_path)
  jobs_data.each do |job_id, job_data|
    job_data[:snippet] = job_data[:snippet].gsub("<b>","").gsub("</b>","")
    # whitelisted_job_post_detected = whitelisted_regex.any? {|re| re =~ job_data[:jobtitle].downcase.split(" ").join(" ")}# split and join removes extraneous white spaces
    blacklisted_job_post_detected = blacklisted_regex.any? {|re| re =~ job_data[:jobtitle].downcase.split(" ").join(" ")} # split and join removes extraneous white spaces
    previously_shared_job_id_detected = previously_shared_job_ids.include?(job_id)

    if [previously_shared_job_id_detected, blacklisted_job_post_detected].none?
    # if whitelisted_job_post_detected && [previously_shared_job_id_detected, blacklisted_job_post_detected].none?
      if filtered_job_data[job_id]
        original_job_files = filtered_job_data[job_id][:job_found_in]
        new_job_files = original_job_files << file_path
        filtered_job_data[job_id] = filtered_job_data[job_id].merge(:job_found_in => new_job_files)
      else
        job_files = [file_path]
        filtered_job_data[job_id] = job_data.merge(:job_found_in => job_files)
      end
    end
  end
end

data_keys_with_permitted_lengths = {company: 25, jobtitle: 40, snippet: 100, formattedLocation: 25, url: 1000}
output_filepath = "#{project_name}/report_in_progress.csv"
CSV.open(output_filepath, "w") do |csv|
  csv << ["company", "jobtitle", "snippet", "location", "url","job_id"]
  filtered_job_data.sort_by{|_,job_data| job_data[:job_found_in].length }.reverse.each do |job_id,job_data|
    record = []
    data_keys_with_permitted_lengths.each do |key, permitted_length|
      data = job_data[key]
      data = "#{data[0..permitted_length].strip}..." if data.length > permitted_length
      record << data
    end
    csv << (record << job_id)
  end
end

puts "#{filtered_job_data.size} results filtered"
