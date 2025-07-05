import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AjouterFabricant extends StatefulWidget {
  @override
  _AjouterFabricantState createState() => _AjouterFabricantState();
}

class _AjouterFabricantState extends State<AjouterFabricant> {
  /*late Web3Client _client;
  late String _rpcUrl;
  late String _privateKey;
  late EthereumAddress _contractAddress;
  late ContractAbi _contractAbi;
  late DeployedContract _contract;
  late Credentials _credentials;*/
  String _selectedRole = 'client';
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'aaa.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT,
            tel TEXT,
            role TEXT
          )
        ''');
      },
    );
  }

  Future<void> _ajouterUtilisateur() async {
    if (_database == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Base de données non initialisée")),
      );
      return;
    }

    try {
      await _database!.insert(
        'utilisateurs',
        {
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'tel': _telController.text,
          'role': _selectedRole,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Ajout réussi ! Stocké dans la base de données locale."),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'ajout: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _database?.close();
    super.dispose();
  }
  /* @override
  void initState() {
    super.initState();
    _rpcUrl = "HTTP://127.0.0.1:7545";
    _privateKey =
        "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a";

    _contractAddress =
        EthereumAddress.fromHex("0xd234F69c4151ACDB3720e61334393A3B0808985a");
    _contractAbi = ContractAbi.fromJson("""
 
    """, "FabricantContract");
    _client = Web3Client(_rpcUrl, http.Client());
    _getContract();
  }

  _getContract() async {
    _contract = DeployedContract(_contractAbi, _contractAddress);
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  _ajouterFabricant() async {
    try {
      var ajouterFabricantFunction = _contract.function("ajouterFabricant");
      final transaction = Transaction.callContract(
        contract: _contract,
        function: ajouterFabricantFunction,
        parameters: [
          _nomController.text,
          _prenomController.text,
          _emailController.text,
          _telController.text,
        ],
        gasPrice: EtherAmount.inWei(BigInt.from(1000000000)), // 1 GWei
        maxGas: 300000,
      );

      // Envoyer la transaction
      await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 1337, // ID de Sepolia
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ajout réussie et stockée sur la blockchain!"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint(
          'Erreur a lors de l\'ajout: $e'); // Afficher l'erreur complète dans la console
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'ajout: $e"),
        ),
      );
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Fabricant ajouté avec succès")));
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter Utilisateur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: "Nom")),
            TextField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: "Prénom")),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: _telController,
                decoration: InputDecoration(labelText: "Téléphone")),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ['client', 'fabricant', 'fournisseur', 'transporteur']
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(labelText: "Sélectionner un rôle"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _ajouterUtilisateur,
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}
