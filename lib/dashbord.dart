import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suiviedeschaine/commande/listecommande.dart';
import 'package:suiviedeschaine/main.dart';
//import 'package:suiviedeschaine/entrepot.dart';
import 'package:suiviedeschaine/statistique.dart';
import 'package:suiviedeschaine/Fabricant/listfabricant.dart';
//import 'package:suiviedeschaine/fournisseur/listfournisseur.dart';
import 'package:suiviedeschaine/produit/ProduitListPage.dart';
/*import 'package:suiviedeschaine/Récepteur/listrecepteur.dart';
import 'package:suiviedeschaine/Transporteur/listtransporteur.dart';*/
//import 'package:suiviedeschaine/payement/payement.dart';
import 'package:suiviedeschaine/camion/ajoutcamion.dart';
import 'package:suiviedeschaine/entrepot/WarehouseManagementPage.dart';
import 'package:suiviedeschaine/qrcode/ajout_produit.dart';
import 'package:suiviedeschaine/qrcode/visualisation_client.dart';

class Dashbord extends StatelessWidget {
  final String role;
  final String ide;
  final String nom;

  Dashbord({required this.role, required this.ide, required this.nom});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supply Chain Dashboard'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('camion'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AjoutCamion(userRole: role)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('commande'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommandesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('users'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListFabricant(userRole: role)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('entrepot'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListeEntrepotsPage(userRole: role)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('produit'),
              onTap: () {
                // Navigation vers la page des commandes
                print(role);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProduitListPage(userRole: role, ide: ide, nom: nom)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('QRcode'),
              onTap: () {
                if (role == "ouner") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AjoutProduit()),
                  );
                } else if (role == "client") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VisualisationClient()),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('statistique'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp1()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('log out'),
              onTap: () {
                // Navigation vers la page des commandes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top KPIs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKpiCard('Active Orders', '120'),
                _buildKpiCard('Pending Deliveries', '45'),
                _buildKpiCard('Completed', '300'),
              ],
            ),
            SizedBox(height: 16),
            // Map and recent shipments
            Expanded(
              child: Row(
                children: [
                  /*GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(48.8566, 2.3522),
                      zoom: 10, // Niveau de zoom initial
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('location1'),
                        position: LatLng(48.8566, 2.3522), // Position de Paris
                        infoWindow: InfoWindow(title: "Entrepôt Paris"),
                      ),
                    },
                  ),*/
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Live Map Placeholder',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Recent Shipments
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Recent Shipments',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView(
                              children: [
                                _buildShipmentItem(
                                    '12', 'In Transit', Colors.blue),
                                _buildShipmentItem(
                                    '100', 'Delivered', Colors.green),
                                _buildShipmentItem(
                                    '20', 'Pending', Colors.orange),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentItem(String order, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(order, style: TextStyle(fontSize: 16)),
          Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
