require 'net/http'
require 'uri'
require 'optparse'

## inside libs
load 'shodan_class.rb'
load 'viewdns.rb'
load 'censys_search.rb'
load 'colors.rb'
load 'zoomeye.rb'

banner_tool = '

    Author: Gh0sTNiL
    Version: 2.0

################################################################################


 █████╗ ███╗   ██╗ █████╗ ██╗  ██╗   ██╗███████╗███████╗██████╗ ██████╗
██╔══██╗████╗  ██║██╔══██╗██║  ╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗██╔══██╗
███████║██╔██╗ ██║███████║██║   ╚████╔╝   ███╔╝ █████╗  ██████╔╝██║  ██║
██╔══██║██║╚██╗██║██╔══██║██║    ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗██║  ██║
██║  ██║██║ ╚████║██║  ██║███████╗██║   ███████╗███████╗██║  ██║██████╔╝
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝



USAGE: ruby analyzerD.rb -u https://target.com --all

    -u, --url TARGET                 Target for crawler
    -s, --shodan                     [+] Shodan search
    -d, --viewdns                    [+] ip history from viewDNS
    -c, --censys                     [+] Censys Search Certificate search, ivp4 and more
    -a, --all                        [+] Use all methods
    -z, --zoomeye                    [+] Zoomeye ip search
    -h, --help                       Show this entire menu

################################################################################
'.red


def url_parse(url)
  uri = URI.parse(url)
  if uri.scheme != "http" && uri.scheme != "https"
    puts "\n\n[+] You provide a target without a HTTP schema => #{url}\n\n[+] All requests will be made with https://#{url}".red
    url = "https://" + url
  end
  return url
end


## MENU ##
options = {}
optparse = OptionParser.new do |opts|

  opts.banner = "USAGE: ruby #{__FILE__} https://target.com"

  opts.on("-u", "--url TARGET", "Target for crawler") do |u|
    options[:url] = u
  end

  opts.on("-s", "--shodan", "[+] Shodan search") do |s|
    options[:shodan] = s
  end

  opts.on("-d", "--viewdns", "[+] ip history from viewDNS") do |v|
    options[:viewdns] = v
  end

  opts.on("-c", "--censys", "[+] Censys Search Certificate search, ivp4 and more") do |c|
    options[:censys] = c
  end

  opts.on("-z", "--zoom", "[+] ZOOMEYE Search") do |z|
    options[:zoom] = z
  end

  opts.on("-a", "--all", "[+] Use all methods") do |al|
    options[:all] = al
  end

  opts.on( '-h', '--help', 'Show this entire menu' ) do
    puts opts
    exit
  end
end
optparse.parse!

puts banner_tool

## threat inputs menu
if options[:url].nil?
  abort(optparse.help)
end

url = options[:url]
parsed_url = url_parse(url)
url = parsed_url

if options[:shodan]
  puts "\n\n [+] Verify if your api key is set on shodan_class.rb file\n\n [+] Initialize Shodan Search \n\n".magenta
  shodan_objt = ShodanSearch.new(parsed_url)
  shodan_objt.shodan_search()
end

if options[:censys]
  puts "\n\n [+] Verify if your api key is set on censys_search.rb file\n\n [+] Initialize Censys Search Search \n\n".magenta
  censys_objt = CensysSearch.new(parsed_url)
  censys_objt.censys_search_ipv4()
end

if options[:zoom]
  puts "\n\n [+] Verify if your api key is set on zoomeye.rb file\n\n [+] Initialize ZOOM Search Search \n\n".magenta
  zoom_objt = ZoomApi.new(parsed_url)
  zoom_objt.dork_search()
end

if options[:viewdns]
  puts "\n\n [+] Verify if your api key is set on viewdns.rb file\n\n [+] Initialize viewDNS Search \n\n".magenta
  viewdns_objt = ViewDns.new(parsed_url)
  viewdns_objt.retrive_info_api()
end

if options [:all]
  puts "\n\n[+] USING ALL METHODS [+]\n\n".magenta
  shodan_objt = ShodanSearch.new(parsed_url)
  shodan_objt.shodan_search()
  viewdns_objt = ViewDns.new(parsed_url)
  viewdns_objt.retrive_info_api()
  censys_objt = CensysSearch.new(parsed_url)
  censys_objt.censys_search_ipv4()
  censys_objt.censys_search_websites()
end
