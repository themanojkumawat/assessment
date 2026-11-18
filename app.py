import os
import time
from flask import Flask, jsonify

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-key")

APP_NAME = os.getenv("APP_NAME", "flask-devops-service")
ENVIRONMENT = os.getenv("ENVIRONMENT", "production")
START_TIME = time.time()

@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "status": "success",
        "message": "Flask DevOps API is running successfully",
        "app_name": APP_NAME,
        "environment": ENVIRONMENT
    }), 200

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "service": APP_NAME,
        "environment": ENVIRONMENT,
        "uptime_seconds": int(time.time() - START_TIME),
        "timestamp": int(time.time())
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({"status": "error", "message": "not found"}), 404

if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 5000))
    app.run(host=host, port=port)
