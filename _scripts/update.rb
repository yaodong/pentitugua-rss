#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

base_url  = 'http://www.dapenti.com/blog'
list_url  = "#{base_url}/blog.asp?subjectid=70&name=xilei"
keyword   = '喷嚏图卦'

list_html = Nokogiri::HTML(open(list_url))
links = list_html.css 'div[align="left"] ul li a'
links.each do |link|
  if link.text.include? keyword

    # parse date
    date_str = link.text[/2\d+/]
    year, month, day = [date_str[0,4], date_str[4..-3], date_str[-2..-1]]
    month = "0#{month}" if month.length < 2

    # post file path
    file = "#{__dir__}/../_posts/#{year}-#{month}-#{day}-#{year}#{month}#{day}.md"

    unless File.exist? file
      url       = "#{base_url}/#{link['href']}"
      article   = Nokogiri::HTML(open(url), nil, 'gbk')
      date_time = article.css('div[align="right"] span.oblog_text').first.text[/[\d-]+ [\d:]+/]

      content   = "---\n"
      content   += "layout: post\n"
      content   += "title: \"#{link.text}\"\n"
      content   += "date: #{date_time}\n"
      content   += "link: #{url}\n"
      content   += "---\n\n"
      content   += article.css('div.oblog_text').first.to_s.encode('utf-8')

      File.write file, content
    end

  end
end
