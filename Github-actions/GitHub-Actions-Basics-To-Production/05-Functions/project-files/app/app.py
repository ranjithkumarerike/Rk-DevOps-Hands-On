from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/")
def home():
    app.logger.info("Homepage endpoint invoked")

    return jsonify(
        message="Welcome to Cloud With VarJosh",
        platform="GitHub Actions",
        runtime="Docker + Flask"
    )

@app.get("/health")
def health():
    app.logger.info("Health check endpoint invoked")

    return jsonify(status="healthy"), 200

if __name__ == "__main__":
    app.logger.info("Starting Flask application")

    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", 5000))
    )# Feature Branch Change
# Additional PR Change
# Feature branch Change
# Additional PR Change
