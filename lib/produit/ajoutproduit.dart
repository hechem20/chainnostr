import 'dart:convert' show base64Encode;
import 'dart:io' show File;

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
/*import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';*/

import 'package:image_picker/image_picker.dart';
// ignore: deprecated_member_use
//import 'dart:html' as html;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Nom de la base de données
  static const String dbName = 'produit.db';

  // Créer et ouvrir la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);
    await deleteDatabase(path);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Création de la table
  Future _createDB(Database db, int version) async {
    const String createTable = '''
      CREATE TABLE produits (
        id TEXT PRIMARY KEY,
        description TEXT,
        price INTEGER,
        qte INTEGER,
        status TEXT,
        img TEXT
      );
    ''';
    await db.execute(createTable);
  }

  // Insérer un produit
  Future<int> insertProduit(Map<String, dynamic> produit) async {
    final db = await instance.database;
    return await db.insert('produits', produit);
  }

  // Récupérer tous les produits
  Future<List<Map<String, dynamic>>> getProduits() async {
    final db = await instance.database;
    return await db.query('produits');
  }
}

class AjoutProduit extends StatefulWidget {
  @override
  _AjoutProduitState createState() => _AjoutProduitState();
}

class _AjoutProduitState extends State<AjoutProduit> {
  String selectedRole = "Cree";
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController qte = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageBase64;

  Future<void> _pickImage() async {
    // Créer une instance de ImagePicker
    final picker = ImagePicker();

    // Choisir l'image depuis la galerie
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Lire l'image comme base64 (ou File si nécessaire)
      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(bytes); // Convertir en base64

      setState(() {
        _imageBase64 = imageBase64; // Stocker le résultat dans l'état
      });
    } else {
      print("Aucune image sélectionnée.");
    }
  }

  Future<void> _saveProductToDatabase() async {
    final productData = {
      'id': _idController.text,
      'description': _descriptionController.text,
      'price': int.parse(_priceController.text),
      'qte': int.parse(qte.text),
      'status': selectedRole,
      'img': _imageBase64 ?? '',
    };

    await DatabaseHelper.instance.insertProduit(productData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produit ajouté à la base de données!")),
    );

    _idController.clear();
    _descriptionController.clear();
    _priceController.clear();
    qte.clear();
    setState(() {
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Produit")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: "Code produit")),
              TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description")),
              TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Prix")),
              TextField(
                  controller: qte,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Quantité")),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _imageBase64 == null
                    ? Container(
                        width: 156,
                        height: 148,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.network(
                        _imageBase64!,
                        width: 156,
                        height: 148,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ["Cree", "Stock", "Expedie", "Livre", "Recu"]
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: "Sélectionnez votre rôle",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProductToDatabase,
                child: Text("Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
