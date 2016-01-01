#!/usr/bin/env ruby -wKU

require "bundler"
require "pry"
Bundler.require :default

# puts "Getting base page"
base_url  = URI.parse "http://www.anarchyishyperbole.com/p/significant-digits.html"
base_html = Net::HTTP.get base_url
base_doc  = Nokogiri::HTML base_html

puts "Now getting links"
links = base_doc.css("div#post-body-1033655653480284046 a")

chapter_uris = links.map do |link|
  link['href']
end.select do |url|
  url =~ /significant-digits-/
end.map do |url|
  URI.parse url
end

# move glossary to the end
chapter_uris += [chapter_uris.shift]

chapter_uris.each_with_index do |chapter_uri, index|
  html = Net::HTTP.get chapter_uri
  doc  = Nokogiri::HTML html
  content = doc.css("div.post")[0]

  # Rewrite Chapter Titles
  content.css("h3").each do |h3|
    h3.content = h3.text.split(':')[-1]
  end

  # Replace double <br> with wrapping <p>
  #via http://stackoverflow.com/questions/8937846/how-do-i-wrap-html-untagged-text-with-p-tag-using-nokogiri
  # content.search("//br/preceding-sibling::text()|//br/following-sibling::text()").each do |node|
  #   if node.content !~ /\A\s*\Z/ and node.node_type == Nokogiri::XML::Node::TEXT_NODE
  #     node.replace(Nokogiri.make("<p>#{node.to_html}</p>"))
  #   end
  # end

  # Remove duplicated headers
  content.css("span").select do |node|
    # binding.pry
    node.remove if node.text =~ /Chapter/
  end

  # Remove empty <i> linebreaks
  content.css("i").select do |node|
    node.remove if node.text.strip.empty?
  end

  # Remove post footer
  content.css("div.post-footer").remove
  content.css("div.post-header").remove
  content.css("a").remove

  # content.css('br').remove

  # Write to file
  open("chapters/chapter-" + index.to_s + ".html", "w") do |file|
    file << content
  end
end