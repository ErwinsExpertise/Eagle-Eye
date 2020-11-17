# Eagle-Eye

Eagle-Eye is a webscraper that is used to monitor the stock of specific items in popular stores

## Store
- Walmart
- BestBuy
- NewEgg
- Playstation Direct

# Set Up

## Environment

- Ruby 2.6+

### Dependecies

gem 'nokogiri'
gem 'toml'
gem 'open-uri'
gem 'discordrb'
gem 'zlib'

### Environment Variables
Discord Webhook URL's for notification channel and health-check


**Example**
Exporting environment variables:

	Exporting environment variables on Linux:

	export DISCORD_URL=https://discordapp.com/api/webhooks/Token/Key
	export HEALTH_URL=https://discordapp.com/api/webhooks/Token/Key
	

## Discord

### Webhooks

https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks


# To Do

- [ ] Fix Playstation Direct
- [ ] Fix Amazon
- [ ] Add checkout capabilities
