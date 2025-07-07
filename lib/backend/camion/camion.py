from flask import Flask, request, jsonify
from datetime import datetime
import uuid
import hashlib
import time
import json
import requests
from ecdsa import SigningKey, SECP256k1

app = Flask(__name__)

# Clé privée Nostr (exemple) — à remplacer par la tienne
PRIVATE_KEY_HEX = "1f0aa9c3e6a2090c70aa10f6e3d48fef367308507b1649022ec23f6ab2fc9f94"

# Création d’une instance secp256k1
privkey = bytes.fromhex(PRIVATE_KEY_HEX)
signing_key = SigningKey.from_string(privkey, curve=SECP256k1)
verifying_key = signing_key.get_verifying_key()
pubkey = verifying_key.to_string().hex()

# URL du relai Nostr public
RELAY_URL = "https://nostr-relay.nostr.band/"  # ⚠️ Pour test, certains relais HTTP ne sont pas toujours fiables

def sha256(data):
    return hashlib.sha256(data.encode()).hexdigest()

def sign_event(event):
    serialized_event = json.dumps([
        0,
        event["pubkey"],
        event["created_at"],
        event["kind"],
        event["tags"],
        event["content"]
    ], separators=(',', ':'), ensure_ascii=False)

    event_id = sha256(serialized_event)
    event["id"] = event_id

    sig = signing_key.schnorr_sign(bytes.fromhex(event_id), None, raw=True)
    event["sig"] = sig.hex()
    return event

@app.route("/events", methods=["POST"])
def receive_event():
    payload = request.get_json()
    if not payload:
        return jsonify({"error": "Invalid JSON"}), 400

    # Construire l'événement Nostr
    event = {
        "pubkey": pubkey,
        "created_at": int(time.time()),
        "kind": 1,
        "tags": [],
        "content": json.dumps(payload),
    }

    signed_event = sign_event(event)

    # Envoyer l’événement au relai (en POST — pour test, sinon utiliser WebSocket dans production)
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(RELAY_URL, headers=headers, data=json.dumps(signed_event))
        print(f"[✅] Événement envoyé au relai : {signed_event['id']}")
        return jsonify({"status": "sent", "relay": RELAY_URL, "id": signed_event["id"]}), 200
    except Exception as e:
        print(f"[❌] Échec d'envoi : {e}")
        return jsonify({"error": "Failed to send to relay"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5000)


