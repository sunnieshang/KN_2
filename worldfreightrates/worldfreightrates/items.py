# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class WorldfreightratesItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    from_location = scrapy.Field()
    to_location = scrapy.Field()
    value = scrapy.Field()
    weight_kg = scrapy.Field()
    length = scrapy.Field()
    width = scrapy.Field()
    height = scrapy.Field()
    rate = scrapy.Field()
    min_rate = scrapy.Field()
    max_rate = scrapy.Field()
    distance = scrapy.Field()
    time = scrapy.Field()
