require 'toml'
require 'nokogiri'
require 'open-uri'
require 'discordrb/webhooks'
require 'zlib'

class EagleEye
    def initialize
        @DISCORD_URL = ENV["DISCORD_URL"]
        @HEALTH_URL = ENV["HEALTH_URL"]
    end

    def start
        Thread.new {
            Kernel.loop do
                health_check
                sleep(600)
            end
        }
        
        Kernel.loop do
            iterate
            sleep(30) # Check every 30 seconds
        end

    end

    def iterate
        url_list = WebsiteBuilder.new.assign

        url_list.each do | obj |
            Thread.new {
                store, status = obj.scrape
                if status == true 
                    puts("\e[32m#{store}: In stock!\e[0m")
                    msg = store + ": In Stock!\n"
                    send_message(msg, obj.url, @DISCORD_URL)
                else
                    puts("\e[31m#{store}: Out of Stock\e[0m")
                end
            }
        end
    end

    def health_check
        send_message("Bot is alive", "", @HEALTH_URL)
    end

    def send_message(msg, url, discord)
        message = msg + "\n" + url
        begin
            client = Discordrb::Webhooks::Client.new(url: discord)

            client.execute do |builder|
                builder.content = message
            end

        rescue RestClient::NotFound
            puts("Discord Webhook Environment Variables not set!\nDISCORD_URL= #{@DISCORD_URL}\nHEALTH_URL=#{@HEALTH_URL}\n")
            exit(1)
        end
        puts("Sent Discord notification")
    end

end

class WalMart
    attr_accessor :url
    def initialize(url)
        @url = url
    end

    def scrape
        scraper = Scraper.new(@url, ".prod-ProductCTA--primary")
        status = scraper.scrape_site

        if status == true
            return (self.class.name), true
        end

       return (self.class.name), false
        
    end

end



class BestBuy
    attr_accessor :url
    def initialize(url)
        @url = url
    end

    def scrape
        scraper = Scraper.new(@url, ".btn-primary")
        status = scraper.scrape_site

        if status == true
            return (self.class.name), true
        end

       return (self.class.name), false
        
    end
end

class Amazon
    attr_accessor :url
    def initialize(url)
        @url = url
    end

    def scrape
        scraper = Scraper.new(@url, ".add-to-cart")
        status = scraper.scrape_site

        if status == true
            return (self.class.name), true
        end

       return (self.class.name), false
        
    end
end

class NewEgg
    attr_accessor :url
    def initialize(url)
        @url = url
    end

    def scrape
        scraper = Scraper.new(@url, ".btn-primary")
        status = scraper.scrape_site

        if status == true
            return (self.class.name), true
        end

       return (self.class.name), false
        
    end
end

class Playstation
    attr_accessor :url
    def initialize(url)
        @url = url
    end

    def scrape
        scraper = Scraper.new(@url, ".add-to-cart")
        status = scraper.scrape_site

        if status == true
            return (self.class.name), true
        end

       return (self.class.name), false
        
    end
end


class WebsiteBuilder

    def initialize
        @urls = TOML.load_file("item.toml")
    end

    def assign
        url_list = []

        url_list << WalMart.new(@urls["WalMart"]["url"])
        url_list << BestBuy.new(@urls["BestBuy"]["url"])
        url_list << NewEgg.new(@urls["NewEgg"]["url"])
        #url_list << Playstation.new(@urls["Playstation"]["url"])

        # Disabled Amazon due to Captcha
        #url_list << Amazon.new(@urls["Amazon"]["url"])

        return url_list
    end

end


class Scraper

    attr_accessor :url, :button
    def initialize(url, button)
        @url = url
        @button = button
    end

    def scrape_site
        begin

        stream = URI.open(@url,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36",
        "accept" => " text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "accept-encoding" => "gzip, deflate",
        "accept-language"=> "en-US,en;q=0.9",
        )
        rescue OpenURI::HTTPError => e

            puts "Couldn't reach #{@url}, #{e}"
            return true
        end


        if (stream.content_encoding.empty?)
            body = stream.read
        else
            body = Zlib::GzipReader.new(stream).read
        end

        doc = Nokogiri::HTML(body)
        if @button == ""
            @button = ".button"
        end        

        # Playstation check
        if @url.include? "direct.playstation.com"
            ele = doc.css(@button).to_a

            # If element can't be found then the direct queue is up
            if ele.nil?
                return true
            end

            #Find primary
            ele.each do | el |
                if el["data-module-name"] == "hero"
                    if el["class"].include? "hide"
                        return false
                    end
                    return true
                end
            end
        else
            atc = doc.css(@button).find{|x| x.text =~ /add to cart/i || x.text =~ /add/i} 

            if atc.nil?
                return false
            end
        end 

        return true
    end

end

EagleEye.new.start