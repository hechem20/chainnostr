import 'package:flutter/material.dart';
import 'package:suiviedeschaine/payement/payement.dart' show Payement;

class Produit2 extends StatefulWidget {
  List<Map<String, dynamic>>? products;
  final String ide;
  final String nom;

  Produit2({required this.products, required this.ide, required this.nom});
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<Produit2> {
  late int c = 1;
  late int price;
  //late int id = int.parse(widget.id!);
  void _increaseQuantity(int index) {
    setState(() {
      if (widget.products?[0]["qte"] > c) {
        c++;
      }
    });
  }

  // Acheter un produit
  void _buyProduct(int index) {
    int p = c * price;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Achat confirmé"),
          content: Text(
              "Vous avez acheté ${widget.products?[index]["description"]}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Payement(
                        somme: p.toString(),
                        q: widget.products!,
                        ide: widget.ide,
                        nom: widget.nom)),
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    price = int.tryParse(widget.products?[0]["price"].toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
          title: Text("Produit Details")), // Assurez-vous d'avoir une AppBar
      body: Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(widget.products?[0]["description"] ?? "Produit inconnu"),
// Sécurisation de l'accès
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Statut: ${widget.products?[0]["status"] ?? "Inconnu"}"),
              Text("Prix: ${widget.products?[0]["price"] ?? "0"} €"),
              Text("Quantité: ${c}"),
              Text("somme: ${c * price}"),
            ],
          ),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _increaseQuantity(0), // Correction de l'index
              ),
              ElevatedButton(
                onPressed: () => _buyProduct(0), // Correction de l'index
                child: Text("Payer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
