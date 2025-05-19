from flask import Flask, jsonify
from flask_cors import CORS
import json
import os

EXPORT_PATH = "tf2livemap_export.json"

app = Flask(__name__)
CORS(app)  # erlaubt Anfragen vom Frontend

@app.route("/api/data", methods=["GET"])
def get_data():
    if not os.path.exists(EXPORT_PATH):
        return jsonify({"error": "Export file not found"}), 404

    try:
        with open(EXPORT_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)