#!/bin/bash

# Monitoring management script for EC2

MONITORING_DIR=~/monitoring

case "$1" in
    "start")
        echo "🚀 Starting monitoring stack..."
        cd $MONITORING_DIR
        docker-compose up -d
        echo "✅ Monitoring started!"
        echo "📊 Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
        echo "📈 Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
        ;;
    "stop")
        echo "🛑 Stopping monitoring stack..."
        cd $MONITORING_DIR
        docker-compose down
        echo "✅ Monitoring stopped!"
        ;;
    "restart")
        echo "🔄 Restarting monitoring stack..."
        cd $MONITORING_DIR
        docker-compose down
        docker-compose up -d
        echo "✅ Monitoring restarted!"
        ;;
    "status")
        echo "📊 Monitoring stack status:"
        cd $MONITORING_DIR
        docker-compose ps
        ;;
    "logs")
        echo "📋 Monitoring logs:"
        cd $MONITORING_DIR
        docker-compose logs
        ;;
    "update")
        echo "📦 Updating monitoring configuration..."
        cp -r ~/devops-aws-demo/monitoring/* $MONITORING_DIR/
        cd $MONITORING_DIR
        docker-compose down
        docker-compose up -d
        echo "✅ Monitoring updated!"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|update}"
        echo ""
        echo "Commands:"
        echo "  start   - Start monitoring stack"
        echo "  stop    - Stop monitoring stack"
        echo "  restart - Restart monitoring stack"
        echo "  status  - Show monitoring status"
        echo "  logs    - Show monitoring logs"
        echo "  update  - Update monitoring configuration"
        exit 1
        ;;
esac 