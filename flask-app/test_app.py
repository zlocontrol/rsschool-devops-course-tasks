import pytest
from main import app

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
    assert b"Not Found" in response.data or b"The requested URL was not found on the server." in response.data

