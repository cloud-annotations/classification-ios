import requests
import json

url = ('https://newsapi.org/v2/everything?'
       'q=Apple&'
       'from=2019-09-07&'
       'sortBy=popularity&'
       'apiKey=4cb3a0a2c9034ea89d0c16f8336d1eeb')

response = requests.get(url)

#print(json.dumps(response, index=2))
