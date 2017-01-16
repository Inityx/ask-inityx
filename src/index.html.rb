# frozen_string_literal: true
require 'nokogiri'
require 'yaml'
require_relative 'post'

BUILD_DIR = ARGV[0]
abort 'No build directory specified' unless BUILD_DIR
HTML_FILE = File.expand_path('index.html', BUILD_DIR).freeze

POST_DIR = ARGV[1]
abort 'No post directory specified' unless POST_DIR

posts = Dir.glob("#{POST_DIR}/*.yml").sort.reduce({}) do |hash, filename|
  slug = /\d+-(.+).yml$/.match(File.basename(filename))[1]
  post = Post.load(filename)

  hash.merge(slug => post)
end

html = Nokogiri::HTML::Builder.new(encoding: 'utf-8') { |doc|
  doc.html {
    doc.head {
      doc.title {
        doc.text 'Ask Inityx'
      }
      doc.meta(
        name: 'viewport',
        content: 'width=device-width, initial-scale=1'
      )
      doc.link(
        rel: 'stylesheet',
        href: 'index.css',
        type: 'text/css'
      )
      doc.link(
        rel: 'stylesheet',
        href: 'code.css',
        type: 'text/css'
      )
    }
    doc.body {
      doc.header {
        doc.h1 {
          doc.text 'Ask Inityx'
        }
        doc.h2 {
          doc.text(
            <<-SUBTITLE
Some technology-related questions
I had in high school, and the answers
I never got
            SUBTITLE
          )
        }
      }
      doc.aside(id: 'table-of-contents') {
        doc.ol {
          posts.each do |slug, post|
            doc.a(href: "##{slug}") {
              doc.li { doc << post.title }
            }
          end
        }
      }
      doc.main {
        posts.each do |slug, post|
          doc.section(class: 'post') {
            doc.a(name: slug)
            doc.h3 {
              doc << post.title
            }
            doc.article {
              post.content.each do |paragraph|
                if %w(text mark).include?(paragraph.children[0].name)
                  doc.p {
                    doc << paragraph
                  }
                else
                  doc << paragraph
                end
              end
            }
          }
        end
      }
    }
  }
}.to_html

File.open(HTML_FILE, 'w') do |file|
  file.write(html)
end
