#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'openssl'
require 'digest'
require 'fileutils'

class Newsboy

  TITLE_KEYWORD = /喷嚏图卦\s?\d+/
  LINK_KEYWORD  = 'more.asp'
  BASE_URL = 'https://www.dapenti.com/blog'
  LIST_URL = "#{BASE_URL}/index.asp"

  def work
    links = find_article_links
    links.each do |link|
      download_article link
    end
  end

  private

  def find_article_links
    list_html = Nokogiri::HTML(read_url(LIST_URL), nil, 'gbk')
    list_html.css('a').select do |link|
      link.text =~ TITLE_KEYWORD && link['href'].include?(LINK_KEYWORD)
    end
  end

  def download_article(link)
    year, month, day = parse_date(link)
    post_file = "#{__dir__}/../_posts/#{year}/#{year}-#{month}-#{day}-#{year}#{month}#{day}.md"
    download_to_file(link, post_file) unless File.exist?(post_file)
  end

  def parse_date(link)
    date_str = link.text[/2\d+/]
    year  = date_str[0,4]
    month = date_str[4..-3]
    day   = date_str[-2..-1]
    [ year, month, day ]
  end

  def download_to_file(link, post_file)

    puts "Downloading #{link['title']}."

    url       = "#{BASE_URL}/#{link['href']}"
    article   = Nokogiri::HTML(read_url(url), nil, 'gbk')
    date_time = article.css('div[align="right"] span.oblog_text').first.text[/[\d-]+ [\d:]+/]

    content   = "---\n"
    content   += "layout: post\n"
    content   += "title: \"#{link['title']}\"\n"
    content   += "date: #{date_time}\n"
    content   += "link: #{url.gsub('https', 'http')}\n"
    content   += "---\n\n"
    content   += article.css('div.oblog_text').first.to_s.encode('utf-8')

    #content = download_image(content)

    File.write post_file, content
  end

  def download_image(content)
    Nokogiri::HTML(content).xpath("//img/@src").each do |src|
      href = src.value
      next unless href.start_with?('http://') || href.start_with?('https://')
      next unless ['.jpg', '.png'].include?(href[-4..-1])

      img_name = Digest::MD5.hexdigest(href) + '.' + href.split('.').last
      img_path = "images/#{img_name[0]}/#{img_name[1]}/#{img_name[2]}/#{img_name}"
      img_full_path = "#{__dir__}/../#{img_path}"
      img_tag_path  = "../#{img_path}"

      dirname = File.dirname(img_full_path)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      if File.file? img_full_path
        p img_full_path
      else
        File.open(img_full_path, 'wb') do |f|
          p "downloading #{img_name}"
          f.write open(href).read
        end
      end

      content[href] = img_tag_path
    end

    content
  end

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

end
