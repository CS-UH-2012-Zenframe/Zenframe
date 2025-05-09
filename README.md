# Zenframe

Zenframe is a full-stack news reader that helps you focus on uplifting content while still offering crisis-support resources when the feed feels overwhelming. It was built as the final project for NYUAD CS-UH 2012 Software Engineering (Spring 2025).&#x20;

---

## Key Features

* **Good-News-Only filter** — hide articles whose positivity score falls below a user-set threshold.
* **Crisis Support** — one-tap access to helplines and self-help coping strategies, even offline.
* **Commenting & Moderation** — post, edit, and flag comments with profanity and length checks.
* **Emoji Reactions & Happiness rating** — live sentiment bar on every story.
* **AI Summaries** — AI-powered, neutral one-liners for faster reading.&#x20;

---

## Tech Stack

| Layer             | Implementation                               | Notes                                        |
| ----------------- | -------------------------------------------- | -------------------------------------------- |
| iOS client        | **SwiftUI**                                  | Navigation, authentication, state management |
| API service       | **Flask** (Python)                           | REST endpoints, CORS, auth stubs             |
| micro-service     | **LLM API**                                  | Sentiment analysis & summarisation           |
| Database          | **MongoDB** (pymongo / mongomock for tests)  | Articles, users, comments                    |
| Tests             | **pytest + coverage**                        | >90% statement coverage                      |

---

## Quick Start

### Backend
1. Make sure `mongodb` is installed in your system.
2. Get API keys from [NewsAPI](https://newsapi.org/docs/authentication) and [TogetherAPI](https://api.together.xyz/)
* For grading purposes, we will attach our API keys in our report document.
  
```bash
# clone and enter the repo
git clone https://github.com/CS-UH-2012-Zenframe/Zenframe.git
cd Zenframe/server

python3 -m venv .venv && source .venv/bin/activate
pip3 install -r requirements.txt

# rename .env.example to .env and replace NEWS_API_TOKEN and TOGETHER_API_KEY from keys above 
python3 run.py

# the backend server will start running. Please take note of the last IP address shown.
```
### Frontend (iOS)

1. Open `Zenframe/Zenframe.xcodeproj` in Xcode 15 or later.
2. Connect your iPhone using cable to your Macbook.
3. In Constants.swift, replace URL by IP address from above like this:
4. `static let baseURL = "http://10.228.549.50:8000"`
5. Run the app.

---

# Running Tests

#### To run the tests and generate coverage

`cd server`

run `python3 -m coverage run -m pytest --disable-warnings`

#### To see coverage report
run `coverage report`

#### To generate html detailed coverage report
run `coverage html`

---

## License

This repository is distributed for educational purposes only. © 2025 the Zenframe team.

## Authors

Absera T., Hariharan J., Muhammad Asgar F., Muhammad Musa K. — with guidance from CS-UH 2012 staff.&#x20;
