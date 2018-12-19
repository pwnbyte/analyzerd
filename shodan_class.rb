require 'shodanz'
require 'net/http'
require 'net/https'
require 'uri'
require 'set'
require 'json'
require "pretty_table"
load 'colors.rb'



## YOUR API KEY
API_SHODAN = ""


class ShodanSearch
  attr_accessor :url

  def initialize(url)
    @url = url
    @api = API_SHODAN
  end

  ## shodan_test, test api key
  def shodan_test

    if API_SHODAN.empty?
      puts "[+] Set your api key ! \n get a free on at [ https://www.shodan.io/ ]"
    end

    client = Shodanz.client.new(key: @api)
    url_api_shodan = "https://api.shodan.io/api-info?key=#{@api}"

    ## verify shodancreds
    uri = URI.parse(url_api_shodan)
    response = Net::HTTP.get_response(uri)
    if response.code != "200"
        puts "[+] Something is wrong with your api key shodan \n".red
        puts "[-] Error api key => #{response.code}".red
    end
  end

def shodan_search
  client = Shodanz.client.new(key: @api)
  shodan_test()
  begin

    uri_target = URI.parse(@url)
    host_ip = client.rest_api.resolve(uri_target.host)
    host_ip = host_ip.values[0]
    data_shodan_host = client.rest_api.host(host_ip, history: true)

    puts "[+] SHODAN RESULTS [+] \n".green
    data_search = ['ip_str', 'isp', 'ports', 'last_update']
    data_shodan_host.each do |key, value|
      data_search.each do |index|
        if key == index
          puts "[+] Quick Shodan Results: #{key} ==> #{value}".green
        end
      end
    end

    ips_founded = []
    data = client.rest_api.host_search(uri_target.host)
    result = data['matches']
    result.each do |value|
      value.each do |arr|
        if arr[0] == 'ip_str'
          ips_founded << arr[1]
        end
      end
    end

  if ips_founded.length == 0 || ips_founded.length == 1
    puts "[+] No indexed IPS founded !\n".red
  else
    puts "[+]Shodan ips gathered this could be used to bypass WAF: ==> #{ips_founded}".green
  end

  if data_shodan_host["vulns"].nil?
    puts "[+] no CVES founded !".red
  else
    puts "\n[+]CVEs founded! from #{@url.upcase} \n"
    data_shodan_host["vulns"].each do |cve|
      puts "[+] CVE:#{cve}"
    end
  end
  rescue => e
    puts "[+] Error #{e}".red
  end
end

#end class
end
