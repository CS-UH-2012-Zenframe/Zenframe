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
| NLP micro-service | **FastAPI**                                  | Sentiment analysis & summarisation           |
| Database          | **MongoDB** (pymongo / mongomock for tests)  | Articles, users, comments                    |
| CI / Tests        | **pytest + coverage**,                       | >90 % backend statement coverage             |

---

## Quick Start

### Backend

```bash
# clone and enter the repo
git clone https://github.com/CS-UH-2012-Zenframe/Zenframe.git
cd Zenframe/server

python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

python3 run.py
```
### Frontend (iOS)

1. Open `Zenframe/Zenframe.xcodeproj` in Xcode 15 or later.
2. Choose **iPhone 15 Pro** (or any simulator) and press CMD + Run to launch the frontend on the simulator.

---

## Running Tests

### Backend

DETAIL INFO ABOUT RUNNING BACKEND TESTS

### Frontend

DETAIL INFO ABOUT RUNNING FRONTEND TESTS

##To run the Test
python -m pytest tests/ -v --cov=app.models --cov=app.news.routes --cov=app.utils --cov-report=term-missing

---

## License

This repository is distributed for educational purposes only. © 2025 the Zenframe team.

## Authors

Absera T., Hariharan J., Muhammad Asgar F., Muhammad Musa K. — with guidance from CS-UH 2012 staff.&#x20;
