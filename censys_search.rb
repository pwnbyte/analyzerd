require 'net/https'
require 'net/http'
require 'json'
require 'censys'
require 'pry'
load 'colors.rb'

# CENSYS API KEY
API_CENSYS_ID = ""
API_CENSYS_SECRET = ""


class CensysSearch
  def initialize(url)
    @url = url
    @api_id = API_CENSYS_ID
    @api_secret = API_CENSYS_SECRET
  end

  def censys_search_ipv4()
    uri_target = URI.parse(@url)
    api = Censys::API.new(@api_id, @api_secret)
    begin
      puts "\n\n[+] Censys ipv4 relative from #{@url}[+]\n\n".green
      response = api.ipv4.search(query: uri_target.host)
      response.results.each do |i|
        puts "[+] #{i.ip}".green
      end
    rescue => e
      puts "\n[+] Api ERROR #{e}".red
    end
  end

  def censys_search_websites()
    uri_target = URI.parse(@url)
    api = Censys::API.new(@api_id, @api_secret)
    begin
      puts "\n\n[+] Censys domains from #{@url} [+]\n\n".green
      response = api.websites.search(query: uri_target.host)
      response.results.each do |i|
        puts "[+] #{i.domain}".green
      end
    rescue => e
      puts "\n[+] Api ERROR #{e}".red
    end
  end
# end class
end
