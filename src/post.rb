# frozen_string_literal: true
require 'nokogiri'
require 'yaml'

class Post
  attr_reader :title, :content
  def initialize(title, content)
    raise 'Title missing' if title.nil? || title.empty?
    raise 'Content missing' if content.nil? || content.any?(&:empty?)

    @title = Nokogiri::HTML::DocumentFragment.parse(title)
    @content = content.map { |paragraph|
      Nokogiri::HTML::DocumentFragment.parse(paragraph)
    }
  end

  def self.load(filename)
    new(
      *YAML.load_file(filename)
        .values_at('title', 'content')
    )
  end
end
