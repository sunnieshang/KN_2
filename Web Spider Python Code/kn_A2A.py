from selenium import webdriver
from selenium.webdriver.common.proxy import *
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
import sqlite3
import sys
import os
import csv
import selenium

def readystate_complete(doc):
    return doc.execute_script("return document.readyState") == "complete"

start_url = 'http://knlogin.kuehne-nagel.com/apps/airPublicClientQuotation.do?navbarId=14'

connection = sqlite3.connect('./dataA2A4.db')
connection.text_factory = str
connection.row_factory = sqlite3.Row
cursor = connection.cursor()
cursor.execute('CREATE TABLE IF NOT EXISTS input ' +
               '( _from VARCHAR(8), _to VARCHAR(8),' +
               ' weight INTEGER, volume INTEGER)')
cursor.execute('CREATE TABLE IF NOT EXISTS output ' +
               '(_from VARCHAR(8), _to VARCHAR(8),' +
               ' weight INTEGER, volume INTEGER,' +
               'express numeric(15,2), expert numeric(15,2),' +
               ' extend numeric(15,2), currency VARCHAR(3))')
connection.commit()

if len(sys.argv) == 2 and os.path.exists(sys.argv[1]):
    cursor.execute('DELETE from input')
    cursor.execute('DELETE from output')
    with open(sys.argv[1], 'rb') as f:
        reader = csv.reader(f)
        rowindex = 0
        for row in reader:
            if rowindex != 0:
                cursor.execute('INSERT INTO input (_from, _to, weight, volume)' +
                               ' VALUES (?, ?, ?, ?)',
                               tuple(row))
                connection.commit()
            rowindex += 1




def get_prices(use_phantomjs=True):
    time_out = 40
    if not use_phantomjs:
        firefox_profile = FirefoxProfile()
        firefox_profile.set_preference('dom.ipc.plugins.enabled.libflashplayer.so',
                                       'false')
        driver = webdriver.Firefox(firefox_profile)
    else:
        service_args = []
        driver = webdriver.PhantomJS(service_args=service_args)

    rows = cursor.execute('SELECT rowid, _from, _to, weight, volume FROM input')
    input_rows = []
    for row in rows:
        input_rows.append(row)
    first = True
    for id, source, destination, weight, volume in input_rows:
        print id
        values = []
        src = source.split('-')[-1]
        dst = destination.split('-')[-1]
        if int(weight) > 0 and int(volume)> 0:
            driver.get(start_url)
            if first and use_phantomjs:
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@value="Continue"]')))    
                elem.click()
                first = False
            elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//select[@name="cargoRouting.clientQuotationCargoRoutingDts.deliveryTermsEnumId"]/option[@value="3"]')))
            elem.click()
            name = "javascript:knwebstd.lookup.startOverlayLookup('cargoRouting.clientQuotationCargoRoutingDts.departureAirportCode,cargoRouting.departureAirportLabel','getyourquoteAirportLookup.do?typeOfPlace=Departure',0,'',true,true,null);"
            elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//a[@href="%s"]' % (name, ))))
            elem.click()
            elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupSearchFormId"]//input[@name="lookupFilter"]')))
            elem.send_keys(src)
            elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupSearchFormId"]//input[@name="bt_lookup"]')))
            elem.click()
            try:
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupResultFormId"]/select[@name="lookupResultValue"]/option[contains(.,"%s")]' % (src,))))
                elem.click()
            except:
                print "Source %s not found" % destination
            else:
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupButtonFormId"]//input[@name="bt_accept"]')))
                elem.click()
                name = "javascript:knwebstd.lookup.startOverlayLookup('cargoRouting.clientQuotationCargoRoutingDts.destinationAirportCode,cargoRouting.destinationAirportLabel','getyourquoteAirportLookup.do?typeOfPlace=Destination',0,'',true,true,null);"
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//a[@href="%s"]' % (name, ))))
                elem.click()
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupSearchFormId"]//input[@name="lookupFilter"]')))
                elem.send_keys(dst)
                elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupSearchFormId"]//input[@name="bt_lookup"]')))
                elem.click()
                try:
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupResultFormId"]/select[@name="lookupResultValue"]/option[contains(.,"%s")]' % (dst, ))))
                    elem.click()
                except:
                    print "Destination %s not found" % destination
                else:
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//form[@id="lookupButtonFormId"]//input[@name="bt_accept"]')))
                    elem.click()
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//select[@name="cargoRouting.clientQuotationCargoRoutingDts.incotermEnumId"]/option[contains(.,"(DDP)")]')))
                    elem.click()
                    name = "javascript:changeTabWithPost('tab2Header', 'cargoDetails');"
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//a[@href="%s"]' % (name, ))))
                    elem.click()
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="cargoDetails.weightAndDimensionsDts.totalGrossWeight"]')))
                    elem.send_keys(weight)
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="cargoDetails.weightAndDimensionsDts.totalVolume"]')))
                    elem.send_keys(volume)
                    name = "javascript:changeTabWithPost('tab2Header', 'specials');"
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//a[@href="%s"]' % (name, ))))
                    elem.click()
                    # personal information
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="specials.personalInformationDts.company"]')))
                    elem.send_keys('Company')
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//select[@name="specials.personalInformationDts.simpleTitleEnumId"]/option[contains(.,"Mr.")]')))
                    elem.click()
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="specials.personalInformationDts.surname"]')))
                    elem.send_keys('Surname')
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="specials.personalInformationDts.firstName"]')))
                    elem.send_keys('Firstname')
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="specials.personalInformationDts.phoneNumber"]')))
                    elem.send_keys('+123456')
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//input[@name="specials.personalInformationDts.email"]')))
                    elem.send_keys('email@gmail.com')
                    name = "javascript:changeTabToQuotes();"
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//a[@href="%s"]' % (name, ))))
                    elem.click()
                    elem = WebDriverWait(driver, time_out).until(EC.visibility_of_element_located((By.XPATH, '//td[contains(.,"Price Information")]')))
                    for el in driver.find_elements_by_xpath('//tr[@class="knwebstd_result_table_row_1"]/td'):
                        values.append(el.text)
        if len(values) == 0:
            values = [0] * 4
        cursor.execute('INSERT INTO output (_from, _to, weight, volume, express, expert, extend, currency) '+
                       ' VALUES (?,?,?,?,?,?,?,?)', tuple([source, destination, weight, volume] + values))
        cursor.execute('DELETE FROM INPUT WHERE rowid=?', (id,))
        print [source, destination, weight, volume] + values
        connection.commit()
    else:
        print "All information was scraped. Use db2csv.py to get csv file"

get_prices(True)
