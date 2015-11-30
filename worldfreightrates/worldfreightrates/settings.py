# -*- coding: utf-8 -*-

# Scrapy settings for worldfreightrates project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#

BOT_NAME = 'worldfreightrates'

SPIDER_MODULES = ['worldfreightrates.spiders']
NEWSPIDER_MODULE = 'worldfreightrates.spiders'
DOWNLOAD_DELAY = 4
RANDOM_DOWNLOAD_DELAY = True
COOKIES_ENABLED = True

# Crawl responsibly by identifying yourself (and your website) on the user-agent
USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/36.0.1985.125 Chrome/36.0.1985.125 Safari/537.36'
