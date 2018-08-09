from flask import Flask, request, jsonify
from pymemcache.client.base import Client
import sqlite3 as sql
import time
import random
application = Flask(__name__)


def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


def cached_availability(row1, row2, cache):
    key = '{0}_{1}'.format(row1, row2)
    avail = cache.get(key)
    if not avail:
        avail = slow_process_to_calculate_availability(row1, row2)
        cache.set(key, avail, expire=120)
    return avail

@application.route('/hardware/')
def hardware():
    cache = Client(('cache.example.com', 11211))
    con = sql.connect('/opt/web/database.db')
    c = con.cursor()

    statuses = [
        {
            'provider': row[1],
            'name': row[2],
            'availability': cached_availability(
                row[1],
                row[2],
                cache
            ),
        }
        for row in c.execute('SELECT * from hardware')
    ]

    con.close()

    return jsonify(statuses)


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5001)
