import asyncio
import json
import websockets
from flask import Flask, jsonify, request
from threading import Thread

app = Flask(__name__)
products_store = {}  # { product_id: {...} }

NOSTR_RELAY_URL = "wss://relay.damus.io"  # Remplace par ton relay si besoin


# Fonction pour écouter les événements Nostr en WebSocket
async def nostr_listener():
    async with websockets.connect(NOSTR_RELAY_URL) as websocket:
        # Envoi d’une souscription Nostr (REQ) — filtre sur kind ou tag ou content
        subscription_id = "flutter-tracking-sub"
        req_message = [
            "REQ",
            subscription_id,
            {
                "kinds": [30000],  # Tu peux filtrer sur ton kind personnalisé
                # "authors": ["npub1..."],  # optionnel
            }
        ]
        await websocket.send(json.dumps(req_message))
        print(f"✅ Souscription envoyée à {NOSTR_RELAY_URL}")

        while True:
            try:
                message = await websocket.recv()
                decoded = json.loads(message)

                if decoded[0] == "EVENT":
                    event = decoded[2]
                    content = event.get("content")
                    try:
                        product_data = json.loads(content)  # On suppose que le champ content est du JSON
                        product_id = product_data.get("id")
                        if product_id:
                            products_store[product_id] = product_data
                            print(f"🟢 Produit {product_id} mis à jour depuis Nostr.")
                    except Exception as e:
                        print(f"⚠️ Erreur parsing contenu JSON: {e}")

            except websockets.exceptions.ConnectionClosed:
                print("🔴 WebSocket fermé. Reconnexion...")
                await asyncio.sleep(5)
                return await nostr_listener()


# Lancer le listener WebSocket dans un thread séparé
def start_listener():
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(nostr_listener())

# API REST pour accéder aux produits
@app.route("/products/<product_id>", methods=["GET"])
def get_product(product_id):
    product = products_store.get(product_id)
    if not product:
        return jsonify({"error": "Produit non trouvé"}), 404
    return jsonify(product)

@app.route("/products", methods=["GET"])
def list_products():
    return jsonify(list(products_store.values()))

# Démarrage
if __name__ == "__main__":
    # Thread pour le listener
    listener_thread = Thread(target=start_listener)
    listener_thread.daemon = True
    listener_thread.start()

    # Serveur Flask
    print("🚀 Backend REST Flask + Nostr prêt sur http://localhost:5000")
    app.run(host="0.0.0.0", port=5000)
