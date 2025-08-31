import sqlite3
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
app = Flask(__name__)
CORS(app)
def init_db():
    conn = sqlite3.connect("smartwater.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS waterdata (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tankLevel INTEGER,
            flowRate INTEGER,
            totalUsage INTEGER,
            timestamp TEXT
        )
    """)
    conn.commit()
    conn.close()

init_db()  
@app.route("/api/water", methods=["POST"])
def add_water_data():
    try:
        data = request.get_json()

        if not all(k in data for k in ("tankLevel", "flowRate", "totalUsage")):
            return jsonify({"error": "Missing required fields"}), 400

        conn = sqlite3.connect("smartwater.db")
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO waterdata (tankLevel, flowRate, totalUsage, timestamp)
            VALUES (?, ?, ?, ?)
        """, (
            data["tankLevel"],
            data["flowRate"],
            data["totalUsage"],
            datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        ))
        conn.commit()
        conn.close()

        return jsonify({"message": "Data saved successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/water", methods=["GET"])
def get_water_data():
    try:
        conn = sqlite3.connect("smartwater.db")
        cursor = conn.cursor()
        cursor.execute("SELECT tankLevel, flowRate, totalUsage, timestamp FROM waterdata ORDER BY id DESC LIMIT 10")
        rows = cursor.fetchall()
        conn.close()

        result = [
            {"tankLevel": row[0], "flowRate": row[1], "totalUsage": row[2], "timestamp": row[3]}
            for row in rows
        ]

        return jsonify(result[::-1])

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, port=5000)

if __name__ == "__main__":
    app.run(debug=True, port=5000)
