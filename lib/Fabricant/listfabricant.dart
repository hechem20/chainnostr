import 'package:flutter/material.dart';
import 'package:suiviedeschaine/Fabricant/ajoutfabricant.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Nom de la base de données
  static const String dbName = 'aaa.db';

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Création de la table
  Future _createDB(Database db, int version) async {
    const String createTable = '''
      CREATE TABLE utilisateurs (
        nom TEXT,
        prenom TEXT,
        email TEXT PRIMARY KEY,
        tel TEXT,
        role TEXT
      );
    ''';
    await db.execute(createTable);
  }

  // Insérer un utilisateur
  Future<int> insertFabricant(Map<String, dynamic> fabricant) async {
    final db = await instance.database;
    return await db.insert('utilisateurs', fabricant);
  }

  // Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getFabricants() async {
    final db = await instance.database;
    return await db.query('utilisateurs');
  }

  // Rechercher un utilisateur par nom et rôle
  Future<List<Map<String, dynamic>>> searchFabricants(
      String nom, String? role) async {
    final db = await instance.database;
    if (nom.isEmpty && (role == null || role.isEmpty)) {
      return await db.query('utilisateurs');
    } else {
      String query = 'SELECT * FROM utilisateurs WHERE ';
      List<dynamic> args = [];

      if (nom.isNotEmpty) {
        query += 'nom LIKE ? ';
        args.add('%$nom%');
      }
      if (role != null && role.isNotEmpty) {
        if (nom.isNotEmpty) query += ' AND ';
        query += 'role = ?';
        args.add(role);
      }

      return await db.rawQuery(query, args);
    }
  }

  // Mettre à jour un utilisateur
  Future<int> updateFabricant(
      String email, String nom, String prenom, String tel) async {
    final db = await instance.database;
    return await db.update(
      'utilisateurs',
      {'nom': nom, 'prenom': prenom, 'tel': tel},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Supprimer un utilisateur
  Future<int> deleteFabricant(String email) async {
    final db = await instance.database;
    return await db.delete(
      'utilisateurs',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}

class ListFabricant extends StatefulWidget {
  final String userRole;

  ListFabricant({required this.userRole});
  @override
  _ListFabricantState createState() => _ListFabricantState();
}

class _ListFabricantState extends State<ListFabricant> {
  List<Map<String, dynamic>> fabricants = [];
  final TextEditingController _searchController = TextEditingController();
  String? selectedRole;
  List<String> roles = ["client", "fabricant", "fournisseur", "transporteur"];

  @override
  void initState() {
    super.initState();
    fetchFabricants();
  }

  void fetchFabricants() async {
    fabricants = await DatabaseHelper.instance.getFabricants();
    setState(() {});
  }

  void _searchFabricants() async {
    String nom = _searchController.text.trim();
    fabricants =
        await DatabaseHelper.instance.searchFabricants(nom, selectedRole);
    setState(() {});
  }

  void _resetSearch() {
    _searchController.clear();
    selectedRole = null;
    fetchFabricants();
  }

  void _editDialog(Map<String, dynamic> fabricant) {
    TextEditingController nomController =
        TextEditingController(text: fabricant['nom']);
    TextEditingController prenomController =
        TextEditingController(text: fabricant['prenom']);
    TextEditingController telController =
        TextEditingController(text: fabricant['tel']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Modifier le fabricant"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: "Nom")),
            TextField(
                controller: prenomController,
                decoration: InputDecoration(labelText: "Prénom")),
            TextField(
                controller: telController,
                decoration: InputDecoration(labelText: "Téléphone")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateFabricant(
                fabricant['email'],
                nomController.text,
                prenomController.text,
                telController.text,
              );
              Navigator.pop(context);
              fetchFabricants();
            },
            child: Text("Modifier"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
        ],
      ),
    );
  }

  void _deleteFabricant(String email) async {
    await DatabaseHelper.instance.deleteFabricant(email);
    fetchFabricants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des utilisateurs"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher par nom",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _searchFabricants,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedRole,
                  hint: Text("Choisir un rôle"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                    _searchFabricants();
                  },
                  items: roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetSearch),
        ],
      ),
      body: fabricants.isEmpty
          ? Center(child: Text("Aucun utilisateur trouvé"))
          : ListView.builder(
              itemCount: fabricants.length,
              itemBuilder: (context, index) {
                final f = fabricants[index];
                return Card(
                  child: ListTile(
                    title: Text("${f['nom']} ${f['prenom']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${f['email']}"),
                        Text("Téléphone: ${f['tel']}"),
                        Text("Rôle: ${f['role']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.userRole == 'ouner')
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editDialog(f),
                          ),
                        if (widget.userRole == 'ouner')
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFabricant(f['email']),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userRole == 'ouner') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjouterFabricant()),
            ).then((_) => fetchFabricants());
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

/*class _ListFabricantState extends State<ListFabricant> {
  late Web3Client _client;
  late String _rpcUrl;
  late EthereumAddress _contractAddress;
  late ContractAbi _contractAbi;
  late DeployedContract _contract;
  late Credentials _credentials;

  TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _fabricants;
  bool _isSearching = false; // Indique si une recherche est en cours

  @override
  void initState() {
    super.initState();
    _rpcUrl = "HTTP://127.0.0.1:7545";
    _credentials = EthPrivateKey.fromHex(
        "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a");
    _contractAddress =
        EthereumAddress.fromHex("0xd234F69c4151ACDB3720e61334393A3B0808985a");
    _contractAbi = ContractAbi.fromJson("""
    """, "FabricantContract");
    _client = Web3Client(_rpcUrl, http.Client());
    _getContract();
    _fabricants = _getFabricants() as Future<List<Map<String, dynamic>>>?;
  }

  _getContract() async {
    _contract = DeployedContract(_contractAbi, _contractAddress);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _chercherFabricantParNom(
      String nom) async {
    final function = _contract.function("chercherFabricantParNom");
    var result = await _client.call(
      contract: _contract,
      function: function,
      params: [nom],
    );

    List<Map<String, dynamic>> fabricants = [];
    for (var fabricant in result[0]) {
      fabricants.add({
        'nom': fabricant[0],
        'prenom': fabricant[1],
        'email': fabricant[2],
        'tel': fabricant[3],
      });
    }

    return fabricants;
  }

  Future<List<Map<String, dynamic>>>? _getFabricants() async {
    var getFabricantsFunction = _contract.function("getFabricants");
    var result = await _client
        .call(contract: _contract, function: getFabricantsFunction, params: []);
    List<Map<String, dynamic>> fabricants = [];
    for (var fabricant in result[0]) {
      fabricants.add({
        'nom': fabricant[0],
        'prenom': fabricant[1],
        'email': fabricant[2],
        'tel': fabricant[3],
      });
    }
    // _fabricants = fabricants as Future<List<Map<String, dynamic>>>?;
    print(fabricants);
    return fabricants;
  }

  Future<void> _updateFabricant(
      String email, String newNom, String newPrenom, String newTel) async {
    final updateFunction = _contract.function("updateFabricant");

    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: updateFunction,
        parameters: [email, newNom, newPrenom, newTel],
      ),
      chainId: 1337,
    );

    setState(() {});
  }

  Future<void> _deleteFabricant(String email) async {
    final deleteFunction = _contract.function("deleteFabricant");

    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: deleteFunction,
        parameters: [email],
      ),
      chainId: 1337,
    );

    setState(() {});
  }

  void _searchFabricant() async {
    String nom = _searchController.text.trim();
    if (nom.isNotEmpty) {
      List<Map<String, dynamic>> result = await _chercherFabricantParNom(nom);
      setState(() {
        _fabricants = result as Future<List<Map<String, dynamic>>>?;
        _isSearching = true;
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });
  }

  void _showUpdateDeleteDialog(String email) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nomController = TextEditingController();
        TextEditingController prenomController = TextEditingController();
        TextEditingController telController = TextEditingController();

        return AlertDialog(
          title: Text("Modifier ou Supprimer"),
          content: Column(
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: prenomController,
                decoration: InputDecoration(labelText: "Prénom"),
              ),
              TextField(
                controller: telController,
                decoration: InputDecoration(labelText: "Téléphone"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (widget.userRole == 'ouner') {
                  _deleteFabricant(email);
                  Navigator.pop(context);
                }
              },
              child: Text("Supprimer"),
            ),
            TextButton(
              onPressed: () {
                if (widget.userRole == 'ouner') {
                  _updateFabricant(email, nomController.text,
                      prenomController.text, telController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Rechercher un fab...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchFabricant;
                }
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fabricants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun fabricant trouvé"));
          }
          List<dynamic> fabricants = snapshot.data!;
          return ListView.builder(
            itemCount: fabricants.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(fabricants[index]['nom']),
                subtitle: Text(fabricants[index]['prenom']),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fabricants[index]['email']),
                    Text(fabricants[index]['tel']),
                  ],
                ),
                onLongPress: () {
                  _showUpdateDeleteDialog(fabricants[index]['email']);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userRole == 'ouner') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjouterFabricant()),
            );
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter un fabricant',
      ),
    );
  }
}*/
