#!/usr/bin/env python
import sqlite3
import csv

connection = sqlite3.connect('./dataA2A3.db')
connection.text_factory = str
connection.row_factory = sqlite3.Row

ofile  = open('output_A2A3.csv', "wb")
writer = csv.writer(ofile, delimiter='\t', quotechar='"', quoting=csv.QUOTE_ALL)


cursor = connection.cursor()
cursor1 = connection.cursor()
cursor.execute('SELECT DISTINCT _from, _to, weight, volume, express, expert, extend, currency FROM output')
if cursor:
    for row in cursor:
        writer.writerow(tuple(row))
connection.close()
ofile.close()
