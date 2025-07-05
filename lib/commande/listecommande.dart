import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommandesScreen extends StatefulWidget {
  @override
  _CommandesScreenState createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  List commandes = [];
  TextEditingController _searchController = TextEditingController();
  List allCommandes = [];

  @override
  void initState() {
    super.initState();
    _getCommandes();
  }

  Future<void> _getCommandes() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/events?kind=logistics_payment"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = jsonDecode(response.body);
        final List<dynamic> extracted = [];

        for (var event in events) {
          final content = jsonDecode(event['content']);
          extracted.add([
            content['idProduit'],
            content['description'],
            content['montant'],
            content['prixUnitaire'],
            content['acheteurId'],
            content['acheteurNom'],
          ]);
        }

        setState(() {
          commandes = extracted;
          allCommandes = extracted;
        });

        _calculTotal(extracted);
      } else {
        print("Erreur chargement : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur Nostr: $e");
    }
  }

  Future<void> _calculTotal(List p) async {
    List<String> c = [];
    int s = 0;

    for (var commande in p) {
      final produit = commande[1]; // description
      final quantite = 1; // Par défaut 1 commande
      final prix = int.parse(commande[2].toString()); // montant total

      s += prix;

      bool found = false;
      for (int j = 0; j < c.length; j += 2) {
        if (c[j] == produit) {
          int currentQty = int.parse(c[j + 1]);
          c[j + 1] = (currentQty + quantite).toString();
          found = true;
          break;
        }
      }

      if (!found) {
        c.add(produit);
        c.add(quantite.toString());
      }
    }

    print("Produits groupés : $c");
    print("Somme totale : $s");

    SharedPreferences pre = await SharedPreferences.getInstance();
    await pre.setStringList('c', c);
    await pre.setInt('p', p.length);
    await pre.setInt('s', s);
  }

  void _rechercherCommande(String produit) {
    final filtered = allCommandes
        .where((cmd) =>
            cmd[1].toString().toLowerCase().contains(produit.toLowerCase()))
        .toList();

    setState(() {
      commandes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Commandes")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un produit",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () =>
                      _rechercherCommande(_searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: commandes.isEmpty
                ? Center(child: Text("Aucune commande trouvée"))
                : ListView.builder(
                    itemCount: commandes.length,
                    itemBuilder: (context, index) {
                      final commande = commandes[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text("Produit: ${commande[1]}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Somme: ${commande[2]} sat"),
                              Text("Prix unitaire: ${commande[3]} sat"),
                              Text("Email: ${commande[4]}"),
                              Text("Nom: ${commande[5]}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
