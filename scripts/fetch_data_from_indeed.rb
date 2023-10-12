require 'yaml'
require 'indeed-ruby'
require 'fileutils'
require 'active_support/all'

### inputs
project_name = ARGV[0]
###

data_pulls = Dir.entries("projects/#{project_name}/pulled_data") - ['.', '..','.DS_Store']
data_pulls.each do |data_pull|
  puts data_pull
  match_data = /(?<snake_case_query>.*)(?<zip_chunk>\d{5}_search.yml)/.match(data_pull)
  search_query = match_data[:snake_case_query].gsub("_", " ").strip
  zip = match_data[:zip_chunk].gsub("_search.yml", "")
  print "pulling data for \'#{search_query}\' in #{zip}"
  print ' ['

  search_result_inc = 25
  indeed_client = Indeed::Client.new "823633275211689"

  search_result_count = 0
  search_result = [search_result_inc, 25].min
  jobs = {}

  while search_result_count < 1000
    params = {
      q: search_query,
      l: zip,
      userip: '107.77.198.204',
      useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)',
      limit: search_result_inc,
      start: search_result_count
    }

    results = indeed_client.search(params)["results"]
    results.each do |result|
      jobkey = result.delete("jobkey")
      jobs[jobkey] ||= result.symbolize_keys!
    end
    search_result_count += search_result_inc
    print '.'
  end

  filename = search_query.gsub(" ","_").gsub("/", "_") + "_#{zip}_search.yml"
  File.open("projects/#{project_name}/pulled_data/#{filename}", "w") do |f|
    f.write jobs.to_yaml
  end
  print "]"
  puts
end
