require 'net/http'
require 'net/https'
require 'json'
require "pretty_table"
load 'colors.rb'


API_ZOOM_MAIL = ""
API_ZOOM_PASS = ""
PROXY_ADDR = '127.0.0.1'
PROXY_PORT = '8080'

class ZoomApi

    def initialize(url)
        @url = url
        @key = API_ZOOM_MAIL
        @secret = API_ZOOM_PASS
        @url_auth = "https://api.zoomeye.org/user/login"
    end


    def login()
        data = {'username' => API_ZOOM_MAIL.to_s, 'password' => API_ZOOM_PASS.to_s}
        json_headers = {"Content-Type" => "application/json", "Accept" => "application/json"}
        begin
            uri = URI.parse(@url_auth)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl =  true
            response = http.post(uri.path, data.to_json, json_headers)
            puts "[+] login status code #{response.code}".red
            if response.code == "200" and response.body.include?('access_token')
                token = JSON.parse(response.body).to_hash
                access_token_response = token.values
            else
                puts "[-] Something went wrong with your credencials".red
            end
        rescue => e
            puts "#{e}"
        end
        return access_token_response
    end

    def dork_search()

        access_token = login()

        if @url.include?('http://')
            parsed_url = @url.split('http://')[1]
        end

        if @url.include?('https://')
            parsed_url = @url.split('https://')[1]
        end

        ips_array = []
        url = "https://api.zoomeye.org/host/search"
        uri = URI(url)

        headers = {
                'Authorization'=>"JWT #{access_token[0]}",
                'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0'
                
            }
        params = {
            'query' => "site: #{parsed_url}"
        }
        
        uri.query = URI.encode_www_form(params)    
        http = Net::HTTP.new(uri.host, uri.port) #proxy usage http = Net::HTTP.new(uri.host, uri.port, PROXY_ADDR, PROXY_PORT)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        begin
            response = http.get(uri, headers)
            json_response = response.body
        rescue => e
            puts "[-] API ERROR RESPONSE ".red
        end
        
        parsed_json = JSON.parse(json_response)
        begin
            parsed_json["matches"].each do |v|
                ips_array << v["ip"]
            end
        rescue => e
            puts "[-] ERROR #{e}".red
        end
        
        if ips_array.length() < 0
            puts "[-] ZoomEye not found any entry for #{@url} \n".red
        else
            puts "[+] FOUND RESULTS FOR #{@url} [+]".green
            ips_array.each do |v|
                puts "IP: #{v}".green
            end
        end
    end
end