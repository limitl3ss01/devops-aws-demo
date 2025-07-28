from main import app
import json

def test_health():
    client = app.test_client()
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    # Check new health endpoint format
    assert 'status' in data
    assert data['status'] == 'ok'
    assert 'timestamp' in data
    assert 'version' in data
    assert 'checks' in data
    assert data['checks']['database'] == 'ok'
    assert data['checks']['memory'] == 'ok'
    assert data['checks']['disk'] == 'ok'

def test_metrics():
    client = app.test_client()
    response = client.get('/metrics')
    assert response.status_code == 200
    # Check if Prometheus metrics are present
    content = response.get_data(as_text=True)
    assert 'http_requests_total' in content
    assert 'tasks_total' in content

def test_status():
    client = app.test_client()
    response = client.get('/status')
    assert response.status_code == 200
    data = response.get_json()
    assert 'status' in data
    assert data['status'] == 'running'
    assert 'timestamp' in data
    assert 'version' in data
    assert 'metrics' in data
    assert 'total_tasks' in data['metrics']
    assert 'completed_tasks' in data['metrics']
    assert 'pending_tasks' in data['metrics']

def test_add_and_get_task():
    client = app.test_client()
    # Add task
    response = client.post('/tasks', json={'title': 'Test task'})
    assert response.status_code == 201
    task = response.get_json()
    assert task['title'] == 'Test task'
    assert 'id' in task
    assert 'done' in task
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

def test_toggle_task():
    client = app.test_client()
    # Add task
    response = client.post('/tasks', json={'title': 'To toggle'})
    task = response.get_json()
    task_id = task['id']
    initial_status = task['done']
    
    # Toggle task
    response = client.put(f'/tasks/{task_id}/toggle')
    assert response.status_code == 200
    toggled_task = response.get_json()
    assert toggled_task['done'] != initial_status
    
    # Toggle back
    response = client.put(f'/tasks/{task_id}/toggle')
    assert response.status_code == 200
    toggled_back_task = response.get_json()
    assert toggled_back_task['done'] == initial_status

def test_invalid_task_data():
    client = app.test_client()
    # Try to add task without title
    response = client.post('/tasks', json={})
    assert response.status_code == 400
    data = response.get_json()
    assert 'error' in data
    assert 'Title is required' in data['error']

def test_delete_nonexistent_task():
    client = app.test_client()
    # Try to delete non-existent task
    response = client.delete('/tasks/99999')
    assert response.status_code == 404
    data = response.get_json()
    assert 'error' in data
    assert 'Task not found' in data['error'] 