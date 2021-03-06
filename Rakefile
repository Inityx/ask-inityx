# frozen_string_literal: true

require 'rake'
require 'fileutils'

BUILD = './build'
SRC = './src'
POSTS = "#{SRC}/posts"
POST_PATTERN = /^\d+(-.+\.yml)$/

task default: [:style, :build]

task run: [:style, :build, :open]

# Style
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:style)

# Build
task build: [
  :build_dir,
  "#{BUILD}/index.html",
  "#{BUILD}/index.js",
  :css
]

task :build_dir do
  Dir.mkdir(BUILD) unless Dir.exist?(BUILD)
end

file "#{BUILD}/index.html" => (["#{SRC}/index.html.rb", "#{SRC}/post.rb"] + Dir.glob("#{SRC}/posts/*.yml")) do
  ruby "#{SRC}/index.html.rb", BUILD, POSTS
end

file "#{BUILD}/index.js" do
end

task css: ["#{SRC}/index.css", "#{SRC}/code.css"] do
  FileUtils.cp("#{SRC}/index.css", "#{BUILD}/index.css")
  FileUtils.cp("#{SRC}/code.css", "#{BUILD}/code.css")
end

task :open do
  sh 'xdg-open', "#{BUILD}/index.html"
  sleep 1
end

# Renumbering
task :renumber do
  posts = Dir.glob("#{POSTS}/*.yml").map { |filename| File.basename(filename) }.sort
  char_width = (posts.length - 1).to_s.length

  changelist = posts.each_with_index.reduce({}) do |hash, (old_filename, index)|
    basename = POST_PATTERN.match(old_filename)[1]
    new_filename = format("%0#{char_width}d0", index) + basename
    hash.merge(old_filename => new_filename)
  end

  changelist.each do |old, new|
    begin
      FileUtils.mv("#{POSTS}/#{old}", "#{POSTS}/#{new}")
    rescue ArgumentError
      next
    end
  end
end
