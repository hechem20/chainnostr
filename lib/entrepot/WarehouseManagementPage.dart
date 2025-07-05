import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suiviedeschaine/entrepot/ajoutentrepot.dart';

class Entrepot {
  final int id;
  final String name;
  final String location;
  final String stock;
  final String status;
  final double latitude;
  final double longitude;

  Entrepot({
    required this.id,
    required this.name,
    required this.location,
    required this.stock,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory Entrepot.fromMap(Map<String, dynamic> map) {
    return Entrepot(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      stock: map['stock'],
      status: map['status'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

class DatabaseHelperEntrepot {
  static final DatabaseHelperEntrepot _instance =
      DatabaseHelperEntrepot._internal();
  factory DatabaseHelperEntrepot() => _instance;
  DatabaseHelperEntrepot._internal();

  static Database? _database;
  Future<int> updateEntrepot(Entrepot e) async {
    final db = await database;
    return await db.update(
        'entrepot',
        {
          'name': e.name,
          'location': e.location,
          'stock': e.stock,
          'status': e.status,
          'latitude': e.latitude,
          'longitude': e.longitude,
        },
        where: 'id = ?',
        whereArgs: [e.id]);
  }

  Future<int> deleteEntrepot(int id) async {
    final db = await database;
    return await db.delete('entrepot', where: 'id = ?', whereArgs: [id]);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'entrepot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entrepot(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            location TEXT,
            stock TEXT,
            status TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
      },
    );
  }

  Future<List<Entrepot>> getAllEntrepots() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('entrepot');
    return result.map((map) => Entrepot.fromMap(map)).toList();
  }
}

class ListeEntrepotsPage extends StatefulWidget {
  final String userRole;
  ListeEntrepotsPage({required this.userRole});
  @override
  _ListeEntrepotsPageState createState() => _ListeEntrepotsPageState();
}

class _ListeEntrepotsPageState extends State<ListeEntrepotsPage> {
  List<Entrepot> _entrepots = [];
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _chargerEntrepots();
  }

  Future<void> _chargerEntrepots() async {
    final entrepots = await DatabaseHelperEntrepot().getAllEntrepots();
    setState(() {
      _entrepots = entrepots;
    });
  }

  void _showEditDialog(Entrepot e) {
    final nameCtrl = TextEditingController(text: e.name);
    final locCtrl = TextEditingController(text: e.location);
    final stockCtrl = TextEditingController(text: e.stock);
    final statusCtrl = TextEditingController(text: e.status);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Modifier Entrepôt"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: "Nom")),
              TextField(
                  controller: locCtrl,
                  decoration: InputDecoration(labelText: "Localisation")),
              TextField(
                  controller: stockCtrl,
                  decoration: InputDecoration(labelText: "Stock")),
              TextField(
                  controller: statusCtrl,
                  decoration: InputDecoration(labelText: "Statut")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = Entrepot(
                id: e.id,
                name: nameCtrl.text,
                location: locCtrl.text,
                stock: stockCtrl.text,
                status: statusCtrl.text,
                latitude: e.latitude,
                longitude: e.longitude,
              );
              await DatabaseHelperEntrepot().updateEntrepot(updated);
              Navigator.pop(context);
              _chargerEntrepots();
            },
            child: Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Supprimer ?"),
        content: Text("Es-tu sûr de vouloir supprimer cet entrepôt ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelperEntrepot().deleteEntrepot(id);
              Navigator.pop(context);
              _chargerEntrepots();
            },
            child: Text("Supprimer"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Entrepôts")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _entrepots.isNotEmpty
                    ? LatLng(_entrepots[0].latitude, _entrepots[0].longitude)
                    : LatLng(0, 0),
                zoom: 5,
              ),
              markers: _entrepots.map((e) {
                return Marker(
                  markerId: MarkerId(e.id.toString()),
                  position: LatLng(e.latitude, e.longitude),
                  infoWindow: InfoWindow(title: e.name),
                );
              }).toSet(),
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _entrepots.length,
              itemBuilder: (context, index) {
                final e = _entrepots[index];
                return ListTile(
                  title: Text(e.name),
                  subtitle:
                      Text('${e.location} - Stock: ${e.stock} - ${e.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.userRole == 'ouner')
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(e),
                        ),
                      if (widget.userRole == 'ouner')
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(e.id),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userRole == 'ouner') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjoutEntrepot()),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Entrepôts")),
      body: warehouses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(warehouses[index]['name']));
              },
            ),
    );
  }*/

