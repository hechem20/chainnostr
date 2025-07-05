from flask import Flask, request, jsonify
from datetime import datetime
import uuid

app = Flask(__name__)

# 🧠 Stockage en mémoire
nostr_events = []

@app.route("/events", methods=["POST"])
def receive_event():
    data = request.get_json()

    if not data:
        return jsonify({"error": "Invalid JSON"}), 400

    # Assigner un ID unique à chaque événement
    data["id"] = str(uuid.uuid4())
    nostr_events.append(data)
    print(f"[📥] Événement reçu : {data}")
    return jsonify({"status": "ok", "id": data["id"]}), 200

@app.route("/events", methods=["GET"])
def get_events():
    # Filtrer par type si nécessaire
    kind = request.args.get("kind")
    if kind:
        result = [e for e in nostr_events if e.get("kind") == kind]
    else:
        result = nostr_events
    return jsonify(result), 200

@app.route("/")
def hello():
    return "✅ Fake Nostr Relay is running!", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
