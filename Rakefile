begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

task :open do
  `open http://0.0.0.0:4567`
end

task :download_counts do
  puts "Getting download counts from rubygems.org"
  progress = ProgressBar.create
  download_counts = {}

  # Get all unique gem names
  gem_names = File.open("data.json", "r") do |f|
    JSON.parse(f.read)["categories"]
  end.map{|cat| cat['wrappers'].map{|w| w['gem_name'] } }.flatten.uniq.compact
  progress.total = gem_names.count

  # Grab the download count from rubygems.org
  gem_names.each_with_index do |name, index|
    gem_info = Gems.info(name)
    progress.increment
    download_counts[name] = gem_info ? gem_info['downloads'].to_i : 0
  end

  File.open("download_counts.json", "w") do |file|
    file.write Hash[download_counts.sort_by{|k, v| v}.reverse].to_json
  end

  progress.finish
end
