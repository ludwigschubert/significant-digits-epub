#!/usr/bin/env ruby -wKU

$VERBOSE = nil

require 'yaml'
require "bundler"
Bundler.require :default

arcs = File.open("arcs.yml") { |file| YAML.load(file) }

spinner = TTY::Spinner.new('Requesting chapters ... ', format: :spin_2)
spinner.spin

# puts "Getting base page"
base_url  = URI.parse "http://www.anarchyishyperbole.com/p/significant-digits.html"
base_html = Net::HTTP.get base_url
base_doc  = Nokogiri::HTML base_html

links = base_doc.css("div#post-body-1033655653480284046 a")

chapter_uris = links.map do |link|
  link['href']
end.select do |url|
  url =~ /significant-digits-/
end
# move glossary to the end
chapter_uris += [chapter_uris.shift]
chapter_uris.delete "http://links.schubert.io/significant-digits-epub"
# add 'previously on...'
chapter_uris << 'http://www.anarchyishyperbole.com/p/previously-on-harry-potter-and-methods.html'
chapter_uris.map! do |url|
  URI.parse url
end

spinner.stop('Done!')
sort_index = 0
arc_index = 0
chapter_uris.each do |chapter_uri|
  sort_index += 1
  html = Net::HTTP.get chapter_uri
  puts chapter_uri
  doc  = Nokogiri::HTML html
  content = doc.css("div.post")[0]

  # Rewrite Chapter Titles
  chapter_name = nil
  content.css("h3").each do |h3|
    h3.content = h3.text.split("Significant Digits, ").last
    chapter_name = h3.content.split(": ").last.strip
    h3.name = "h2"
  end
  puts "Downloaded \"#{chapter_name}\""

  # Replace double <br> with wrapping <p>
  #via http://stackoverflow.com/questions/8937846/how-do-i-wrap-html-untagged-text-with-p-tag-using-nokogiri
  # content.search("//br/preceding-sibling::text()|//br/following-sibling::text()").each do |node|
  #   if node.content !~ /\A\s*\Z/ and node.node_type == Nokogiri::XML::Node::TEXT_NODE
  #     node.replace(Nokogiri.make("<p>#{node.to_html}</p>"))
  #   end
  # end

  # Remove duplicated headers
  content.css("span").each do |node|
    node.remove if node.text =~ /Chapter/ or node.text =~ /Bonus/
    node.name = "h4" if node.text =~ /≡≡≡Ω≡≡≡/
  end

  # Remove duplicated headers in Arc 2 chapters
  content.css("b").each do |node|
    node.remove if node.text =~ /Chapter/ or node.text =~ /Bonus/ or node.text =~ /Significant Digits Glossary/
    node.name = "h4" if node.text =~ /≡≡≡Ω≡≡≡/
  end

  # Remove empty paragraphs
  content.css("p").each do |node|
    node.remove if node.text.strip == ""
  end

  # Remove SigDigs header image in later chapters
  content.css("div.separator").remove
  content.css("img").remove

  # Remove empty <i> linebreaks
  content.css("i").each do |node|
    node.remove if node.text.strip.empty?
  end

  # Remove post footer
  content.css("div.post-footer").remove
  content.css("div.post-header").remove
  content.css("a").remove

  # content.css('br').remove

  # Write new arc if necessary
  arc = arcs[arc_index]
  if arc and arc['first_chapter_name'] == chapter_name
    open("chapters/" + sort_index.to_s.rjust(3, '0') + "-arc.html", "w") do |file|
      file << "<h1>#{arc['name']}</h1>"
    end
    arc_index += 1
    sort_index += 1
  end

  # Write to file
  open("chapters/" + sort_index.to_s.rjust(3, '0') + "-chapter.html", "w") do |file|
    file << content
  end

end