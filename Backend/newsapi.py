import http.client
import urllib.parse
import json
import time

conn = http.client.HTTPSConnection('api.thenewsapi.com')

api_token = 'YEj5RG7xYUNNsOpqg6uPB8P3H7OS0aoBap1lxImQ'

seen_titles = set()
page = 1
max_pages = 5  # change this as needed

def is_valid_headline(title):
    if not title:
        return False
    words = title.strip().split()
    return len(words) >= 3 and len(title) >= 15

while page <= max_pages:
    params = urllib.parse.urlencode({
        'api_token': api_token,
        'language': 'en',
        'page': page
    })

    conn.request('GET', f'/v1/news/all?{params}')
    res = conn.getresponse()

    if res.status != 200:
        print(f"Request failed with status {res.status}")
        break

    data = res.read()
    news_data = json.loads(data.decode('utf-8'))

    new_articles = 0

    for article in news_data.get('data', []):
        title = article.get('title')
        if title and title not in seen_titles and is_valid_headline(title):
            print(title)
            seen_titles.add(title)
            new_articles += 1

    if new_articles == 0:
        # print("No new valid articles found, stopping.")
        break

    page += 1
    time.sleep(1)  # avoid API rate limits

conn.close()


# import xmltodict
# import requests
# import json

# def getRSS(url: str) -> dict:
#     response = requests.get(url)
#     return xmltodict.parse(response.content)

# def saveRSS(filepath: str, data: dict) -> None:
#     with open(filepath, 'w') as file:
#         json.dump(data, file, indent=4)

# data = getRSS("https://feeds.bbci.co.uk/news/technology/rss.xml")

# saveRSS("database\\rss_feed_0.json", data)

# # now read the news from the saved file
# with open("database\\rss_feed_0.json", 'r') as file:
#     data = json.load(file)
    
#     for item in data['rss']['channel']['item']:
#         print(item['title'])
#         print(item['description'])
#         print(item['link'])
#         print()
