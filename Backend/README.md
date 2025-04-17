# News API Backend

A Flask-based RESTful API for serving news articles with MongoDB integration.

## Setup

1. Install MongoDB if not already installed:
   ```bash
   # macOS (using Homebrew)
   brew tap mongodb/brew
   brew install mongodb-community
   ```

2. Start MongoDB service:
   ```bash
   brew services start mongodb-community
   ```

3. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Unix/macOS
   ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update MongoDB connection settings if needed

6. Run the application:
   ```bash
   flask run
   ```

## API Endpoints

### GET /news
Returns a list of news articles. Supports filtering by:
- `positivity`: Filter articles by positivity percentage (e.g., `/news?positivity=70`)
- `interest`: Filter articles by interest category (e.g., `/news?interest=economy`)

### GET /news/{id}
Returns detailed information about a specific news article, including its comments.

### GET /news/{id}/comments
Returns all comments for a specific news article.

### POST /news/{id}/comments
Add a new comment to a news article.

Request body:
```json
{
    "content": "Your comment text here"
}
```

## Data Structure

### News Article
```json
{
    "_id": "ObjectId",
    "title": "string",
    "body": "string",
    "positivity_percentage": "float",
    "interest": "string",
    "created_at": "datetime"
}
```

### Comment
```json
{
    "_id": "ObjectId",
    "news_id": "ObjectId",
    "content": "string",
    "created_at": "datetime"
}
```