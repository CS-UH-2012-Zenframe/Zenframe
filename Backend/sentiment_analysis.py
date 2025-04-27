
# @app.post("/analyze_sentiment/")
# async def filter_happy_articles(articles: List[Dict[str, str]]):
#     happy_articles = []
#     for article in articles:
#         sentiment = analyze_sentiment(article["content"])
#         happy_articles.append(sentiment)
    
#     return {"happy_articles": happy_articles}

import http.client
import urllib.parse
import json
import time
from together import Together

# --- API keys and setup ---
news_api_token = 'YEj5RG7xYUNNsOpqg6uPB8P3H7OS0aoBap1lxImQ'
llm_api_key = 'a825cecaa78b0575710fce25052992a84858d617ebd32954f57fd6bfff04f2a1'

client = Together(api_key=llm_api_key)

# --- News API fetching ---
conn = http.client.HTTPSConnection('api.thenewsapi.com')
seen_titles = set()
page = 1
max_pages = 2  # limit for demo; increase as needed

def is_valid_headline(title):
    if not title:
        return False
    words = title.strip().split()
    return len(words) >= 3 and len(title) >= 15

while page <= max_pages:
    params = urllib.parse.urlencode({
        'api_token': news_api_token,
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

    for article in news_data.get('data', []):
        title = article.get('title')
        content = article.get('description') or article.get('snippet') or ""

        if title and title not in seen_titles and is_valid_headline(title):
            seen_titles.add(title)

            # --- Send to LLM ---
            prompt = f"""Original Headline: {title}
News Content: {content}

Rewrite the headline to be more positive and less sensationalized. Then, provide a 2-sentence summary of the news in a positive tone.
"""

            response = client.chat.completions.create(
                model="meta-llama/Llama-3-8b-chat-hf",  # Use a suitable model here
                messages=[
                    {"role": "user", "content": prompt}
                ],
            )

            positive_output = response.choices[0].message.content
            print("\n--- Original ---")
            print("📰", title)
            print("\n--- Rewritten & Summarized ---")
            print(positive_output)

    page += 1
    time.sleep(1)

conn.close()
