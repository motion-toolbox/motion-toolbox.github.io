module ToolboxHelpers
  def categories
    @categories ||= begin
      File.open("data.json", "r") do |f|
        JSON.parse(f.read)["categories"]
      end
    end
  end

  def tags
    @tags ||= categories.map {|c|
      c['wrappers'].map {|w|
        w['tags']
      }
    }.flatten.uniq.sort_by(&:downcase)
  end

  def download_counts
    @download_counts ||= begin
      File.open("download_counts.json", "r") do |f|
        JSON.parse(f.read)
      end
    end
  end

  def download_count(gem_name)
    download_counts[gem_name].si
  end

  def sort_by_downloads(wrappers)
    keys = download_counts.keys

    wrappers.sort do |left, right|
      (keys.index(left['gem_name']) || 999) <=> (keys.index(right['gem_name']) || 999)
    end
  end
end

def get_download_counts!
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

get_download_counts! unless ENV['SKIP_GEMS']

helpers ToolboxHelpers

configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
end
