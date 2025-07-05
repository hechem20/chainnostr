from flask import Flask, request, jsonify
import uuid

app = Flask(__name__)

# Stockage en mémoire des événements Nostr (commandes)
nostr_events = []

@app.route("/events", methods=["POST"])
def receive_event():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON"}), 400
    
    # Vérifier que c’est une commande Nostr
    if data.get("kind") != "logistics_payment":
        return jsonify({"error": "Unsupported event kind"}), 400

    # Ajouter un ID unique
    data["id"] = str(uuid.uuid4())
    nostr_events.append(data)
    print(f"[RECEIVED] {data}")
    return jsonify({"status": "ok", "id": data["id"]}), 200

@app.route("/events", methods=["GET"])
def get_events():
    kind = request.args.get("kind")
    if kind:
        filtered = [e for e in nostr_events if e.get("kind") == kind]
    else:
        filtered = nostr_events
    return jsonify(filtered), 200

@app.route("/")
def index():
    return "Fake Nostr Relay for Commandes running!", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
