from flask import Flask, request, jsonify
import uuid
import time
import json
import hashlib
import requests
import secp256k1

app = Flask(__name__)

# Clé privée Nostr (exemple)
PRIVATE_KEY_HEX = "1f0aa9c3e6a2090c70aa10f6e3d48fef367308507b1649022ec23f6ab2fc9f94"
privkey = bytes.fromhex(PRIVATE_KEY_HEX)
signing_key = secp256k1.PrivateKey(privkey)
pubkey = signing_key.pubkey.serialize(compressed=False).hex()[2:]

# Relai Nostr public
RELAY_URL = "https://nostr-relay.nostr.band/"

# Stockage local en mémoire (optionnel)
nostr_events = []

def sha256(data):
    return hashlib.sha256(data.encode()).hexdigest()

def sign_event(event):
    serialized = json.dumps([
        0,
        event["pubkey"],
        event["created_at"],
        event["kind"],
        event["tags"],
        event["content"]
    ], separators=(',', ':'), ensure_ascii=False)
    event_id = sha256(serialized)
    event["id"] = event_id

    sig = signing_key.schnorr_sign(bytes.fromhex(event_id), None, raw=True)
    event["sig"] = sig.hex()
    return event

@app.route("/events", methods=["POST"])
def receive_event():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON"}), 400
    
    # Vérifier que c’est bien une commande logistique (on accepte kind = "logistics_payment")
    if data.get("kind") != "logistics_payment":
        return jsonify({"error": "Unsupported event kind"}), 400

    # Construire un événement Nostr valide
    event = {
        "pubkey": pubkey,
        "created_at": int(time.time()),
        # Pour Nostr, kind est un entier, on peut mapper "logistics_payment" à un numéro, ici 30001 par exemple
        "kind": 30001,
        "tags": [],
        "content": json.dumps(data)
    }

    signed_event = sign_event(event)

    # Stockage local (optionnel)
    nostr_events.append(signed_event)

    # Envoi au relai Nostr publics
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(RELAY_URL, headers=headers, data=json.dumps(signed_event))
        print(f"[SENT to relay] {signed_event['id']}")
        return jsonify({"status": "sent", "id": signed_event["id"], "relay": RELAY_URL}), 200
    except Exception as e:
        print(f"[ERROR sending] {e}")
        return jsonify({"error": "Failed to send to relay"}), 500

@app.route("/events", methods=["GET"])
def get_events():
    kind = request.args.get("kind")
    if kind:
        filtered = [e for e in nostr_events if e.get("kind") == int(kind)]
    else:
        filtered = nostr_events
    return jsonify(filtered), 200

@app.route("/")
def index():
    return "✅ Nostr Logistics Payment Relay running!", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
