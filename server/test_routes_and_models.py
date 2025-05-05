import pytest
from unittest.mock import patch, MagicMock
from app import create_app

import marshmallow
from bson import ObjectId

# Patch scheduler globally for all tests
def pytest_runtest_setup(item):
    patcher = patch('app.scheduler.start_scheduler', lambda: None)
    patcher.start()
    item.addfinalizer(patcher.stop)

# ---- MODELS ----
@patch('app.models.mongo')
def test_create_and_get_user(mock_mongo):
    mock_users = MagicMock()
    mock_users.insert_one.return_value.inserted_id = 'uid'
    mock_users.find_one.return_value = {'_id': 'uid', 'email': 'test@example.com', 'password': 'hashed'}
    mock_mongo.db.Users = mock_users
    from app.models import create_user, get_user_by_email
    uid = create_user('A', 'B', 'test@example.com', 'pw')
    assert uid == 'uid'
    user = get_user_by_email('test@example.com')
    assert user['email'] == 'test@example.com'

@patch('app.models.bcrypt')
def test_verify_password(mock_bcrypt):
    from app.models import verify_password
    mock_bcrypt.verify.return_value = True
    assert verify_password('pw', 'hashed')

@patch('app.models.mongo')
def test_create_and_list_news(mock_mongo):
    mock_news = MagicMock()
    valid_oid = str(ObjectId())
    mock_news.insert_one.return_value.inserted_id = valid_oid
    mock_news.find.return_value.skip.return_value.limit.return_value.sort.return_value = [
        {'_id': valid_oid, 'headline': 'h', 'excerpt': 'e', 'positivity': 50, 'category': 'tech'}
    ]
    mock_news.find_one.return_value = {'_id': valid_oid, 'headline': 'h'}
    mock_mongo.db.News_reserve = mock_news
    from app.models import create_news, list_news, get_news
    nid = create_news(headline='h', excerpt='e', positivity=50, category='tech', full_body='b')
    assert nid == valid_oid
    news = list_news()
    assert news[0]['headline'] == 'h'
    detail = get_news(valid_oid)
    assert detail['news_id'] == valid_oid

@patch('app.models.mongo')
def test_add_and_list_comments(mock_mongo):
    mock_comments = MagicMock()
    mock_comments.insert_one.return_value.inserted_id = 'cid'
    mock_comments.find.return_value.sort.return_value = [
        {'_id': 'cid', 'user_id': 'uid', 'news_id': 'nid', 'comment_content': 'c'}
    ]
    mock_mongo.db.Comments = mock_comments
    from app.models import add_comment, list_comments
    cid = add_comment('uid', 'nid', 'c')
    assert cid == 'cid'
    comments = list_comments('nid')
    assert comments[0]['comment_id'] == 'cid'

# ---- ROUTES ----
def make_client():
    app = create_app(start_scheduler=False)
    app.config['TESTING'] = True
    return app.test_client()

# AUTH ROUTES
@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes._signup_schema')
def test_signup_success(mock_schema, mock_get_user):
    client = make_client()
    mock_schema.load.return_value = {'email': 'a@b.com', 'first_name': 'A', 'last_name': 'B', 'password': 'pw'}
    mock_get_user.return_value = None
    with patch('app.auth.routes.create_user', return_value='uid'), \
         patch('app.auth.routes.create_access_token', return_value='tok'):
        resp = client.post('/signup', json={'email': 'a@b.com', 'first_name': 'A', 'last_name': 'B', 'password': 'pw'})
        assert resp.status_code == 201
        assert 'access_token' in resp.get_json()

@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes._signup_schema')
def test_signup_duplicate_email(mock_schema, mock_get_user):
    client = make_client()
    mock_schema.load.return_value = {'email': 'a@b.com', 'first_name': 'A', 'last_name': 'B', 'password': 'pw'}
    mock_get_user.return_value = True
    resp = client.post('/signup', json={})
    assert resp.status_code == 400
    assert 'error' in resp.get_json()

@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes._signup_schema')
def test_signup_validationerror_marshmallow(mock_schema, mock_get_user):
    client = make_client()
    mock_schema.load.side_effect = marshmallow.ValidationError({'email': ['Not valid']})
    resp = client.post('/signup', json={})
    assert resp.status_code == 400
    assert 'email' in resp.get_json()

@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes._login_schema')
def test_login_validationerror_marshmallow(mock_schema, mock_get_user):
    client = make_client()
    mock_schema.load.side_effect = marshmallow.ValidationError({'email': ['Not valid']})
    resp = client.post('/login', json={})
    assert resp.status_code == 400
    assert 'email' in resp.get_json()

@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes.verify_password')
@patch('app.auth.routes._login_schema')
def test_login_invalid_credentials(mock_schema, mock_verify, mock_get_user):
    client = make_client()
    mock_schema.load.return_value = {'email': 'a@b.com', 'password': 'pw'}
    mock_get_user.return_value = None
    mock_verify.return_value = False
    resp = client.post('/login', json={})
    assert resp.status_code == 401
    assert 'error' in resp.get_json()

@patch('app.auth.routes.get_user_by_email')
@patch('app.auth.routes.verify_password')
@patch('app.auth.routes._login_schema')
def test_login_success(mock_schema, mock_verify, mock_get_user):
    client = make_client()
    mock_schema.load.return_value = {'email': 'a@b.com', 'password': 'pw'}
    mock_get_user.return_value = {'_id': 'uid', 'password': 'pw'}
    mock_verify.return_value = True
    with patch('app.auth.routes.create_access_token', return_value='tok'):
        resp = client.post('/login', json={'email': 'a@b.com', 'password': 'pw'})
        assert resp.status_code == 200
        assert 'access_token' in resp.get_json()

# NEWS ROUTES
@patch('app.news.routes.list_news', return_value=[])
def test_news_list(mock_list_news):
    client = make_client()
    resp = client.get('/news?positivity=50&category=tech&limit=5&offset=0')
    assert resp.status_code == 200
    assert isinstance(resp.get_json(), list)

@patch('app.news.routes.get_news')
@patch('app.news.routes.list_comments')
def test_news_detail_with_comments(mock_list_comments, mock_get_news):
    client = make_client()
    mock_get_news.return_value = {'news_id': 'nid'}
    mock_list_comments.return_value = [{'comment_id': 'cid'}]
    resp = client.get('/news/nid')
    assert resp.status_code == 200
    data = resp.get_json()
    assert 'comments' in data and data['comments'][0]['comment_id'] == 'cid'

@patch('app.news.routes.get_news')
def test_news_detail_not_found(mock_get_news):
    client = make_client()
    mock_get_news.return_value = None
    resp = client.get('/news/doesnotexist')
    assert resp.status_code == 404

# COMMENTS ROUTES
@patch('app.comments.routes.get_news')
@patch('app.comments.routes._comment_schema')
def test_add_comment_validationerror_marshmallow(mock_schema, mock_get_news):
    client = make_client()
    mock_get_news.return_value = True
    mock_schema.load.side_effect = marshmallow.ValidationError({'comment_content': ['Required']})
    with patch('flask_jwt_extended.view_decorators.verify_jwt_in_request', return_value=None):
        resp = client.post('/news/123/add_comment', json={})
        assert resp.status_code == 400
        assert 'comment_content' in resp.get_json()

@patch('app.comments.routes.get_news')
@patch('app.comments.routes._comment_schema')
def test_add_comment_success(mock_schema, mock_get_news):
    client = make_client()
    mock_get_news.return_value = True
    mock_schema.load.return_value = {'comment_content': 'hi'}
    with patch('flask_jwt_extended.view_decorators.verify_jwt_in_request', return_value=None), \
         patch('flask_jwt_extended.get_jwt_identity', return_value='uid'), \
         patch('app.comments.routes.add_comment', return_value='cid'):
        resp = client.post('/news/123/add_comment', json={})
        assert resp.status_code == 201
        assert 'comment_id' in resp.get_json()

@patch('app.comments.routes.get_news')
def test_add_comment_news_not_found(mock_get_news):
    client = make_client()
    mock_get_news.return_value = None
    resp = client.post('/news/123/add_comment', json={})
    assert resp.status_code == 404
    assert 'error' in resp.get_json()

# ---- INIT/ERROR HANDLERS ----
def test_error_handlers_precise():
    app = create_app()
    client = app.test_client()
    # 400
    @app.route('/force400')
    def force400():
        from flask import abort
        abort(400, description='bad req')
    resp = client.get('/force400')
    assert resp.status_code == 400
    assert resp.get_json()['error'] == 'bad req'
    # 401
    @app.route('/force401')
    def force401():
        from flask import abort
        abort(401, description='unauth')
    resp = client.get('/force401')
    assert resp.status_code == 401
    assert resp.get_json()['error'] == 'unauth'
    # 500
    @app.route('/force500')
    def force500():
        raise Exception('fail')
    resp = client.get('/force500')
    assert resp.status_code == 500
    assert resp.get_json()['error'] == 'Internal server error'
