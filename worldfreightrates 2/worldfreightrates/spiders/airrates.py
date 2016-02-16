# -*- coding: utf-8 -*-
import scrapy
import csv
import rson
from worldfreightrates.items import WorldfreightratesItem
from scrapy.selector import Selector
import re


class AirratesSpider(scrapy.Spider):
    name = "airrates"
    allowed_domains = ["worldfreightrates.com"]
    csv_file = None

    def __init__(self, csv_file=None, *args, **kwargs):
        super(AirratesSpider, self).__init__(*args, **kwargs)
        self.csv_file = csv_file

    def start_requests(self):
        request = scrapy.Request('http://worldfreightrates.com/en/freight',
                                 callback=self.parse)
        yield request

    def parse(self, response):
        with open(self.csv_file, 'rb') as f:
            reader = csv.reader(f)
            rowindex = 0
            for row in reader:
                if rowindex != 0:
                    from_location, to_location, value, weight_kg, length, width, height = tuple(row)
                    for insured in ['false']:
                        data = {
                            'fromName': '(%s)' % from_location.split('-')[-1],
                            'toName': '(%s)' % to_location.split('-')[-1],
                            'oceanType': '',
                            'commodityName': 'General Merchandise',
                            'commodityValue': value,
                            'includeInsurance': insured,
                            'includeReefer': 'false',
                            'includeHazardous': 'false',
                            'weight': weight_kg,
                            'unit': 'kg',
                            'length': length,
                            'width': width,
                            'height': height,
                        }
                        formdata = {
                            'term': data['fromName'],
                        }
                        request = scrapy.FormRequest('http://worldfreightrates.com/calculator/airportcodes',
                                                     formdata=formdata, dont_filter=True,
                                                     method='GET', callback=self.parse_from)
                        request.meta['data'] = data
                        request.meta['from_location'] = from_location
                        request.meta['to_location'] = to_location
                        yield request
                rowindex += 1

    def parse_from(self, response):
        json = rson.loads(response.body)
        data = response.meta['data']
        if len(json) >= 1:
            data['fromId'] = json[0]['id']
            data['fromName'] = json[0]['label']
        formdata = {
            'term': data['toName'],
        }
        request = scrapy.FormRequest('http://worldfreightrates.com/calculator/airportcodes',
                                     formdata=formdata, dont_filter=True,
                                     method='GET', callback=self.parse_to)
        request.meta['data'] = data
        request.meta['from_location'] = response.meta['from_location']
        request.meta['to_location'] = response.meta['to_location']
        yield request

    def parse_to(self, response):
        json = rson.loads(response.body)
        data = response.meta['data']
        if len(json) >= 1:
            data['toId'] = json[0]['id']
            data['toName'] = json[0]['label']
        headers = {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept-Encoding': 'gzip,deflate,sdch',
            'Connection': 'keep-alive',
        }
        if ('fromId' not in data) or ('toId' not in data):
            item = WorldfreightratesItem()
            item['from_location'] = data['fromName']
            item['to_location'] = data['toName']
            item['value'] = data['commodityValue']
            item['weight_kg'] = data['weight']
            item['length'] = data['length']
            item['width'] = data['width']
            item['height'] = data['height']
            item['rate'] = ''
            item['min_rate'] = ''
            item['max_rate'] = ''
            yield item
        else:
            request = scrapy.FormRequest('http://worldfreightrates.com/en/calculator/air/rate',
                                         formdata=data, dont_filter=True,
                                         headers=headers,
                                         method='GET', callback=self.parse_rate)
            request.meta['data'] = data
            request.meta['from_location'] = response.meta['from_location']
            request.meta['to_location'] = response.meta['to_location']
            yield request

    def parse_rate(self, response):
        json = rson.loads(response.body)
        item = WorldfreightratesItem()
        data = response.meta['data']
        item['from_location'] = response.meta['from_location']
        item['to_location'] = response.meta['to_location']
        item['value'] = data['commodityValue']
        item['weight_kg'] = data['weight']
        item['length'] = data['length']
        item['width'] = data['width']
        item['height'] = data['height']
        item['insured'] = data['includeInsurance']
        item['rate'] = json['rate'] if float(data['weight']) < 250 else json['rate'] +' contact carrier'
        hxs = Selector(text=json['result'])
        try:
            result = hxs.xpath('//p[@class="result"]/text()').extract()[0].split('-')
            item['min_rate'] = result[0].strip()
            item['max_rate'] = result[1].strip()
        except:
            item['min_rate'] = ''
            item['max_rate'] = ''
        for text in hxs.xpath('//div[contains(@class, "resultBox")]/text()').extract():
            match = re.match(r'^Distance\:(.+)Time traveled\:(.+)$', text.strip())
            if match:
                item['distance'] = re.sub(r'\s+', ' ', match.group(1).strip()).replace(u'\xa0', ' ')
                item['time'] = re.sub(r'\s+', ' ', match.group(2).strip())
        yield item
