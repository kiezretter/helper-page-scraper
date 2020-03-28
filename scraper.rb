require 'bundler'
require 'nokogiri'
require 'open-uri'
require 'csv'

INDEX_URL = ENV.fetch('INDEX_URL')

CSV($stdout) do |csv|
  csv << ['name', 'street', 'zip', 'city', 'url']
  page_number = 0

  while true
    page_number += 1
    $stderr.puts "Page #{page_number}"
    index_page = Nokogiri::HTML(open(INDEX_URL + "?product-page=#{page_number}"))
    instance_links = index_page.search('a.woocommerce-loop-product__link')
    break if instance_links.empty?

    instance_links.uniq {|link| link['href']}.each do |instance_link|
      url = instance_link['href']
      $stderr.puts url
      instance_page = Nokogiri::HTML(open(url))
      name = instance_page.search('h1').first.content
      address_para = instance_page.search('.et_pb_wc_description_1_tb_body').first
      if address_para
        address = address_para.inner_text.strip
        begin
          street, zip_and_city = address.split(',')
          zip, city = zip_and_city.split(' ')
        rescue
          $stderr.puts "Error parsing address. Skipping #{url}"
          next
        end
        csv << [name, street, zip, city, url]
        csv.flush
        sleep 0.2
      else
        $stderr.puts "Address not found. Skipping #{url}"
      end
    end
  end
end
