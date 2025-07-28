from flask import Flask, request, jsonify
import logging
import time
import json
from datetime import datetime, timezone
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from pythonjsonlogger import jsonlogger

# Configure structured logging
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    fmt='%(asctime)s %(name)s %(levelname)s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency')
ACTIVE_REQUESTS = Gauge('http_requests_active', 'Active HTTP requests')
TASK_COUNT = Gauge('tasks_total', 'Total number of tasks')
TASK_COMPLETED = Gauge('tasks_completed', 'Number of completed tasks')

tasks = [
    {'id': 1, 'title': 'Buy milk', 'done': False},
    {'id': 2, 'title': 'Write DevOps project documentation', 'done': False},
    {'id': 3, 'title': 'Deploy app to AWS EC2', 'done': True},
    {'id': 4, 'title': 'Test GitHub Actions deployment', 'done': False}
]
task_id = 5

def update_task_metrics():
    """Update task-related metrics"""
    TASK_COUNT.set(len(tasks))
    completed_tasks = len([task for task in tasks if task['done']])
    TASK_COMPLETED.set(completed_tasks)

@app.before_request
def before_request():
    """Log request details and start timing"""
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()
    
    logger.info('Request started', extra={
        'method': request.method,
        'endpoint': request.endpoint,
        'path': request.path,
        'remote_addr': request.remote_addr,
        'user_agent': request.headers.get('User-Agent', 'Unknown')
    })

@app.after_request
def after_request(response):
    """Log response details and record metrics"""
    if hasattr(request, 'start_time'):
        duration = time.time() - request.start_time
        REQUEST_LATENCY.observe(duration)
        
        logger.info('Request completed', extra={
            'method': request.method,
            'endpoint': request.endpoint,
            'status_code': response.status_code,
            'duration': duration,
            'response_size': len(response.get_data())
        })
    
    ACTIVE_REQUESTS.dec()
    REQUEST_COUNT.labels(method=request.method, endpoint=request.endpoint, status=response.status_code).inc()
    
    return response

@app.route('/health')
def health():
    """Enhanced health check endpoint"""
    try:
        # Basic health checks
        health_status = {
            'status': 'ok',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'version': '1.0.0',
            'checks': {
                'database': 'ok',  # Placeholder for future DB integration
                'memory': 'ok',
                'disk': 'ok'
            }
        }
        
        logger.info('Health check performed', extra={'status': 'ok'})
        return jsonify(health_status), 200
    except Exception as e:
        logger.error('Health check failed', extra={'error': str(e)})
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks with monitoring"""
    try:
        logger.info('Retrieving all tasks', extra={'task_count': len(tasks)})
        update_task_metrics()
        return jsonify(tasks), 200
    except Exception as e:
        logger.error('Error retrieving tasks', extra={'error': str(e)})
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/tasks', methods=['POST'])
def add_task():
    """Add new task with monitoring"""
    global task_id
    try:
        data = request.get_json()
        if not data or 'title' not in data:
            logger.warning('Invalid task data provided', extra={'data': data})
            return jsonify({'error': 'Title is required'}), 400
        
        task = {'id': task_id, 'title': data['title'], 'done': False}
        tasks.append(task)
        task_id += 1
        
        logger.info('Task created successfully', extra={
            'task_id': task['id'],
            'task_title': task['title']
        })
        
        update_task_metrics()
        return jsonify(task), 201
    except Exception as e:
        logger.error('Error creating task', extra={'error': str(e)})
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete task with monitoring"""
    global tasks
    try:
        original_count = len(tasks)
        tasks = [t for t in tasks if t['id'] != task_id]
        
        if len(tasks) < original_count:
            logger.info('Task deleted successfully', extra={'task_id': task_id})
            update_task_metrics()
            return '', 204
        else:
            logger.warning('Task not found for deletion', extra={'task_id': task_id})
            return jsonify({'error': 'Task not found'}), 404
    except Exception as e:
        logger.error('Error deleting task', extra={'error': str(e), 'task_id': task_id})
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/tasks/<int:task_id>/toggle', methods=['PUT'])
def toggle_task(task_id):
    """Toggle task completion status with monitoring"""
    try:
        for task in tasks:
            if task['id'] == task_id:
                task['done'] = not task['done']
                logger.info('Task status toggled', extra={
                    'task_id': task_id,
                    'new_status': task['done']
                })
                update_task_metrics()
                return jsonify(task), 200
        
        logger.warning('Task not found for toggle', extra={'task_id': task_id})
        return jsonify({'error': 'Task not found'}), 404
    except Exception as e:
        logger.error('Error toggling task', extra={'error': str(e), 'task_id': task_id})
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/status')
def status():
    """Application status endpoint with detailed metrics"""
    try:
        status_info = {
            'status': 'running',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'version': '1.0.0',
            'metrics': {
                'total_tasks': len(tasks),
                'completed_tasks': len([t for t in tasks if t['done']]),
                'pending_tasks': len([t for t in tasks if not t['done']])
            },
            'endpoints': [
                '/health',
                '/metrics',
                '/tasks',
                '/status'
            ]
        }
        
        logger.info('Status check performed', extra={'status': 'running'})
        return jsonify(status_info), 200
    except Exception as e:
        logger.error('Status check failed', extra={'error': str(e)})
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    # Initialize metrics
    update_task_metrics()
    
    logger.info('Application starting', extra={
        'host': '0.0.0.0',
        'port': 5000,
        'environment': 'development'
    })
    
    app.run(host='0.0.0.0', port=5000)