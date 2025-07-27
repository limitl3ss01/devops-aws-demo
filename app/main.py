from flask import Flask, request, jsonify

app = Flask(__name__)

tasks = [
    {'id': 1, 'title': 'Buy milk', 'done': False},
    {'id': 2, 'title': 'Write DevOps project documentation', 'done': False},
    {'id': 3, 'title': 'Deploy app to AWS EC2', 'done': True},
    {'id': 4, 'title': 'Test GitHub Actions deployment', 'done': False}
]
task_id = 5

@app.route('/health')
def health():
    return {'status': 'ok'}, 200

@app.route('/tasks', methods=['GET'])
def get_tasks():
    return jsonify(tasks), 200

@app.route('/tasks', methods=['POST'])
def add_task():
    global task_id
    data = request.get_json()
    if not data or 'title' not in data:
        return {'error': 'Title is required'}, 400
    task = {'id': task_id, 'title': data['title'], 'done': False}
    tasks.append(task)
    task_id += 1
    return jsonify(task), 201

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    global tasks
    tasks = [t for t in tasks if t['id'] != task_id]
    return '', 204

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 