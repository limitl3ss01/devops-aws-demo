#!/usr/bin/env python3
"""
Test script for monitoring setup
Generates load on the Flask app and verifies metrics
"""

import requests
import time
import json
from datetime import datetime

# Configuration
FLASK_APP_URL = "http://localhost:5000"
PROMETHEUS_URL = "http://localhost:9090"
GRAFANA_URL = "http://localhost:3000"

def test_flask_app():
    """Test Flask application endpoints"""
    print("🧪 Testing Flask application...")
    
    # Test health endpoint
    try:
        response = requests.get(f"{FLASK_APP_URL}/health")
        print(f"✅ Health check: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False
    
    # Test metrics endpoint
    try:
        response = requests.get(f"{FLASK_APP_URL}/metrics")
        print(f"✅ Metrics endpoint: {response.status_code}")
        if "http_requests_total" in response.text:
            print("   ✅ Prometheus metrics found")
        else:
            print("   ❌ No Prometheus metrics found")
    except Exception as e:
        print(f"❌ Metrics endpoint failed: {e}")
        return False
    
    # Test status endpoint
    try:
        response = requests.get(f"{FLASK_APP_URL}/status")
        print(f"✅ Status endpoint: {response.status_code}")
        status_data = response.json()
        print(f"   Tasks: {status_data['metrics']['total_tasks']}")
        print(f"   Completed: {status_data['metrics']['completed_tasks']}")
    except Exception as e:
        print(f"❌ Status endpoint failed: {e}")
        return False
    
    return True

def generate_load():
    """Generate load on the application"""
    print("\n📊 Generating load on application...")
    
    # Get initial tasks
    try:
        response = requests.get(f"{FLASK_APP_URL}/tasks")
        initial_tasks = len(response.json())
        print(f"   Initial tasks: {initial_tasks}")
    except:
        initial_tasks = 0
    
    # Add some tasks
    for i in range(3):
        task_data = {"title": f"Test task {i+1} - {datetime.now().isoformat()}"}
        try:
            response = requests.post(f"{FLASK_APP_URL}/tasks", json=task_data)
            if response.status_code == 201:
                print(f"   ✅ Added task {i+1}")
            else:
                print(f"   ❌ Failed to add task {i+1}")
        except Exception as e:
            print(f"   ❌ Error adding task {i+1}: {e}")
    
    # Toggle some tasks
    try:
        response = requests.get(f"{FLASK_APP_URL}/tasks")
        tasks = response.json()
        if tasks:
            task_id = tasks[0]['id']
            response = requests.put(f"{FLASK_APP_URL}/tasks/{task_id}/toggle")
            if response.status_code == 200:
                print(f"   ✅ Toggled task {task_id}")
            else:
                print(f"   ❌ Failed to toggle task {task_id}")
    except Exception as e:
        print(f"   ❌ Error toggling task: {e}")
    
    # Make multiple requests to generate metrics
    print("   🔄 Making multiple requests...")
    for i in range(10):
        try:
            requests.get(f"{FLASK_APP_URL}/tasks")
            requests.get(f"{FLASK_APP_URL}/health")
            time.sleep(0.1)
        except:
            pass
    
    print("   ✅ Load generation completed")

def test_prometheus():
    """Test Prometheus metrics"""
    print("\n📈 Testing Prometheus...")
    
    try:
        # Check if Prometheus is running
        response = requests.get(f"{PROMETHEUS_URL}/api/v1/status/config")
        if response.status_code == 200:
            print("✅ Prometheus is running")
        else:
            print("❌ Prometheus is not responding")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to Prometheus: {e}")
        return False
    
    # Check if Flask app metrics are being scraped
    try:
        response = requests.get(f"{PROMETHEUS_URL}/api/v1/targets")
        targets = response.json()
        flask_target = None
        for target in targets['data']['activeTargets']:
            if 'flask-app' in target['labels']['job']:
                flask_target = target
                break
        
        if flask_target:
            if flask_target['health'] == 'up':
                print("✅ Flask app target is healthy")
            else:
                print("❌ Flask app target is unhealthy")
        else:
            print("❌ Flask app target not found")
    except Exception as e:
        print(f"❌ Error checking targets: {e}")
    
    return True

def test_grafana():
    """Test Grafana"""
    print("\n📊 Testing Grafana...")
    
    try:
        response = requests.get(f"{GRAFANA_URL}/api/health")
        if response.status_code == 200:
            print("✅ Grafana is running")
        else:
            print("❌ Grafana is not responding")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to Grafana: {e}")
        return False
    
    return True

def main():
    """Main test function"""
    print("🔍 Monitoring Test Suite")
    print("=" * 50)
    
    # Test Flask app
    if not test_flask_app():
        print("\n❌ Flask app tests failed. Make sure the app is running on port 5000")
        return
    
    # Generate load
    generate_load()
    
    # Wait for metrics to be scraped
    print("\n⏳ Waiting for metrics to be scraped...")
    time.sleep(15)
    
    # Test Prometheus
    test_prometheus()
    
    # Test Grafana
    test_grafana()
    
    print("\n" + "=" * 50)
    print("🎯 Test completed!")
    print("\n📋 Next steps:")
    print("1. Open Grafana: http://localhost:3000 (admin/admin)")
    print("2. Add Prometheus data source: http://prometheus:9090")
    print("3. Import dashboard from grafana-dashboard.json")
    print("4. View metrics in Prometheus: http://localhost:9090")

if __name__ == "__main__":
    main() 