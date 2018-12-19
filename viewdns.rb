require 'net/http'
require 'net/https'
require 'uri'
require "pretty_table"
require 'json'
load 'colors.rb'

API_VIEWDNS = ""

class ViewDns
  def initialize(url)
    @url = url
    @api = API_VIEWDNS
  end

  def retrive_info_api()

    uri = URI.parse(@url)
    url_api_full = "https://api.viewdns.info/iphistory/?domain=#{uri.host}&apikey=#{@api}&output=json"

    begin
      uri = URI.parse(url_api_full)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request["Accept"] = "*/*"
      request["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0"
      response = http.request(request)

      if response.body.length < 0
        puts "[-] Something went wrong with API Body response".red
        exit!
      end

      puts "\n\n[+] ViewDns IP History RESULTS [+]\n\n".green
      my_hash = JSON.parse(response.body)
      my_hash['response'].each do |k1|
        k1[1].each do |k2|
          puts "#{PrettyTable.new(k2).to_s}".green
        end
      end
    rescue => e
      puts "#{e}".red
    end
  end
#end class
end
