#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'openssl'

# read url and ignore SSL verify
def read_url(url)
  uri = URI(url)
  response = nil
  Net::HTTP.start(
      uri.host, uri.port,
      :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
    request  = Net::HTTP::Get.new uri.request_uri
    response = https.request request
  end
  response.body
end

def is_tg_link(link)
  return false unless link.text =~ /喷嚏图卦\s?\d+/
  return false unless link['href'].include? 'more.asp?name=xilei&id='

  true
end

base_url  = 'https://www.dapenti.com/blog'
list_url  = "#{base_url}/index.asp"

list_html = Nokogiri::HTML(read_url(list_url), nil, 'gbk')
links = list_html.css 'a'
links.each do |link|
  if is_tg_link(link)

    # parse date
    date_str = link.text[/2\d+/]
    year, month, day = [date_str[0,4], date_str[4..-3], date_str[-2..-1]]
    month = "0#{month}" if month.length < 2

    # post file path
    file = "#{__dir__}/../_posts/#{year}/#{year}-#{month}-#{day}-#{year}#{month}#{day}.md"

    unless File.exist? file

      puts "Downloading #{link['title']}."

      url       = "#{base_url}/#{link['href']}"
      article   = Nokogiri::HTML(read_url(url), nil, 'gbk')
      date_time = article.css('div[align="right"] span.oblog_text').first.text[/[\d-]+ [\d:]+/]

      content   = "---\n"
      content   += "layout: post\n"
      content   += "title: \"#{link['title']}\"\n"
      content   += "date: #{date_time}\n"
      content   += "link: #{url.gsub('https', 'http')}\n"
      content   += "---\n\n"
      content   += article.css('div.oblog_text').first.to_s.encode('utf-8')

      File.write file, content
    end

  end
end
