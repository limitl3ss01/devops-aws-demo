from main import app
 
def test_health():
    client = app.test_client()
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json == {'status': 'ok'}

def test_add_and_get_task():
    client = app.test_client()
    # Add task
    response = client.post('/tasks', json={'title': 'Test task'})
    assert response.status_code == 201
    task = response.get_json()
    assert task['title'] == 'Test task'
    # Get tasks
    response = client.get('/tasks')
    assert response.status_code == 200
    tasks = response.get_json()
    assert any(t['title'] == 'Test task' for t in tasks)

def test_delete_task():
    client = app.test_client()
    # Add task
    response = client.post('/tasks', json={'title': 'To delete'})
    task = response.get_json()
    task_id = task['id']
    # Delete task
    response = client.delete(f'/tasks/{task_id}')
    assert response.status_code == 204
    # Check if deleted
    response = client.get('/tasks')
    tasks = response.get_json()
    assert not any(t['id'] == task_id for t in tasks) 