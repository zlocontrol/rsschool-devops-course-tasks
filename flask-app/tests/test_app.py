
import pytest
from flask_app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index_page(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello, Flask!" in response.data

def test_nonexistent_page(client):
    response = client.get('/nonexistent-page')
    assert response.status_code == 404
