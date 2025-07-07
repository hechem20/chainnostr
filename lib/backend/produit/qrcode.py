import asyncio
import json
import websockets
from flask import Flask, jsonify, request
from threading import Thread

app = Flask(__name__)
products_store = {}  # Stockage en mémoire des produits reçus { product_id: product_data }

# URL du relai Nostr public (tu peux changer selon ton choix)
NOSTR_RELAY_URL = "wss://relay.damus.io"

async def nostr_listener():
    while True:
        try:
            async with websockets.connect(NOSTR_RELAY_URL) as websocket:
                subscription_id = "flutter-tracking-sub"
                req_message = [
                    "REQ",
                    subscription_id,
                    {
                        "kinds": [30000]  # Filtrer sur ton kind personnalisé (ici 30000 = produit)
                    }
                ]
                await websocket.send(json.dumps(req_message))
                print(f"✅ Souscription envoyée à {NOSTR_RELAY_URL}")

                async for message in websocket:
                    decoded = json.loads(message)

                    if decoded[0] == "EVENT":
                        event = decoded[2]
                        content = event.get("content")
                        try:
                            product_data = json.loads(content)  # On attend du JSON dans content
                            product_id = product_data.get("id")
                            if product_id:
                                products_store[product_id] = product_data
                                print(f"🟢 Produit {product_id} mis à jour depuis Nostr.")
                        except Exception as e:
                            print(f"⚠️ Erreur parsing contenu JSON: {e}")

        except (websockets.exceptions.ConnectionClosed, ConnectionRefusedError) as e:
            print(f"🔴 WebSocket déconnecté ({e}). Reconnexion dans 5 secondes...")
            await asyncio.sleep(5)
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            await asyncio.sleep(5)

def start_listener():
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(nostr_listener())

# API REST pour accéder aux produits stockés
@app.route("/products/<product_id>", methods=["GET"])
def get_product(product_id):
    product = products_store.get(product_id)
    if not product:
        return jsonify({"error": "Produit non trouvé"}), 404
    return jsonify(product)

@app.route("/products", methods=["GET"])
def list_products():
    return jsonify(list(products_store.values()))

if __name__ == "__main__":
    # Lancer le listener Nostr en thread séparé
    listener_thread = Thread(target=start_listener, daemon=True)
    listener_thread.start()

    print("🚀 Backend Flask + Nostr Relay prêt sur http://localhost:5000")
    app.run(host="0.0.0.0", port=5000)
