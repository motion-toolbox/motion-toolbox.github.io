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

  def star_counts
    @star_counts ||= begin
      File.open("star_counts.json", "r") do |f|
        JSON.parse(f.read)
      end
    end
  end

  def star_count(github)
    puts "star_count: #{github} - #{star_counts[github]}"
    (star_counts[github] || 0).si
  end

  def sort_by_downloads(wrappers)
    keys = star_counts.keys

    wrappers.sort do |left, right|
      (keys.index(left['github']) || 999) <=> (keys.index(right['github']) || 999)
    end
  end
end

def get_star_counts!
  puts "Getting star counts from Github"
  progress = ProgressBar.create
  star_counts = {}

  # Get all unique github urls
  repos_names = File.open("data.json", "r") do |f|
    JSON.parse(f.read)["categories"]
  end.map{|cat| cat['wrappers'].map{|w| w['github'] } }.flatten.uniq.compact
  progress.total = repos_names.count
  puts repos_names
  puts repos_names.count

  # Grab the download count from rubygems.org
  if File.exist?(".oauth_token")
    github = Github.new(oauth_token: File.read(".oauth_token").chomp)
  else
    puts "Please set up a github personal token and put it in the .oauth_token file."
    puts "\nhttps://github.com/settings/tokens\n\n"
    abort
  end

  repos_names.each_with_index do |name, index|
    repo_parts = name.split("/")
    repo_info = github.repos(user: repo_parts[0], repo: repo_parts[1]).get
    star_counts[name] = repo_info.stargazers_count
    progress.increment
  end

  File.open("star_counts.json", "w") do |file|
    file.write Hash[star_counts.sort_by{|k, v| v}.reverse].to_json
  end

  progress.finish
end

get_star_counts! unless ENV['SKIP_GITHUB']

helpers ToolboxHelpers

configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
end
