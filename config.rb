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

helpers ToolboxHelpers

configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
end
