import 'package:flutter/material.dart';
/*import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';*/
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// Database helper
class DatabaseHelperEntrepot {
  static final DatabaseHelperEntrepot _instance =
      DatabaseHelperEntrepot._internal();
  factory DatabaseHelperEntrepot() => _instance;
  DatabaseHelperEntrepot._internal();

  static Database? _database;

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

  Future<int> insertEntrepot(String name, String location, String stock,
      String status, double latitude, double longitude) async {
    final db = await database;
    return await db.insert('entrepot', {
      'name': name,
      'location': location,
      'stock': stock,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}

// Page AjoutEntrepot sans blockchain
class AjoutEntrepot extends StatefulWidget {
  @override
  _AjoutEntrepotState createState() => _AjoutEntrepotState();
}

class _AjoutEntrepotState extends State<AjoutEntrepot> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _stockController = TextEditingController();
  final _statusController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  Future<void> _ajouterEntrepot() async {
    try {
      await DatabaseHelperEntrepot().insertEntrepot(
        _nameController.text,
        _locationController.text,
        _stockController.text,
        _statusController.text,
        double.tryParse(_latitudeController.text) ?? 0.0,
        double.tryParse(_longitudeController.text) ?? 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Entrepôt ajouté localement avec succès")),
      );

      // Réinitialiser les champs
      _nameController.clear();
      _locationController.clear();
      _stockController.clear();
      _statusController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Entrepôt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nom de l'entrepôt"),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Localisation"),
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: "Stock (%)"),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: "Statut"),
            ),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _ajouterEntrepot,
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}

/*class _AjoutEntrepotState extends State<AjoutEntrepot> {
  late Web3Client _client;
  late String _rpcUrl;
  late String _privateKey;
  late EthereumAddress _contractAddress;
  late ContractAbi _contractAbi;
  late DeployedContract _contract;
  late Credentials _credentials;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _stockController = TextEditingController();
  final _statusController = TextEditingController();
  int _id = 0;

  @override
  void initState() {
    super.initState();
    _rpcUrl = "HTTP://127.0.0.1:7545"; // Infura ou autre node Ethereum
    _privateKey =
        "0xefb9baf370d1f5d61076810ec8f9b09f1db907176fa601c11ece406c1109eef5"; // Clé privée pour signer les transactions
    _contractAddress = EthereumAddress.fromHex(
        "0xe27fc022AD9b4cb2a0FCb5178c7C95f218dDcabD"); // Adresse du contrat déployé
    _contractAbi = ContractAbi.fromJson("""
   
    """, "EntrepotContract");
    _client = Web3Client(_rpcUrl, http.Client());
    _getContract();
  }

  _getContract() async {
    _contract = DeployedContract(_contractAbi, _contractAddress);
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  _ajouterEntrepot() async {
    var ajouterEntrepotFunction = _contract.function("ajouterEntrepot");
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: ajouterEntrepotFunction,
        parameters: [
          BigInt.from(_id),
          _nameController.text,
          _locationController.text,
          _stockController.text,
          _statusController.text,
        ],
      ),
      chainId: 1337, // Testnet ou mainnet
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Entrepôt ajouté avec succès")));
    setState(() {
      _id++; // Incrémentation automatique de l'ID
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Entrepôt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nom de l'entrepôt"),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Localisation"),
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: "Stock (%)"),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: "Statut"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _ajouterEntrepot,
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}*/
