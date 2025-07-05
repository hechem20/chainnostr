import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
/*import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';*/
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'userss.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertUser(
      String email, String password, String role, String nom) async {
    final db = await database;
    return await db.insert(
      'users',
      {'nom': nom, 'email': email, 'password': password, 'role': role},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nomprenom = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String selectedRole = "fournisseur";
  Future<void> registerUser(String email, String password, String conf,
      String role, String nom) async {
    try {
      if (conf == password) {
        bh(role);
        await DatabaseHelper().insertUser(email, password, role, nom);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Utilisateur enregistré localement !")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("verifier password!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement : $e")),
      );
    }
  }

  //final String rpcUrl =
  // "https://sepolia.infura.io/v3/812e07e10ce44f45a30c17f1da6d9a36"; // URL du nœud blockchain
  /* final String rpcUrl = "HTTP://127.0.0.1:7545";
  final String wsUrl = "ws://127.0.0.1:7545";
  final String contractAddress =
      "0x2d2055A24DdC417D0939141588897A0B8e8C1AcD"; // Adresse du contrat déployé
  final String privateKey =
      "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a";
  // Ajustement des frais de la transaction

  Future<void> registerUser(String email, String password, String role) async {
    try {
      final client = Web3Client(rpcUrl, Client());
      final credentials = EthPrivateKey.fromHex(privateKey);
      final String contractAbi = '''
[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "role",
				"type": "string"
			}
		],
		"name": "addItem",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			}
		],
		"name": "getUser",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "ItemsInInventory",
		"outputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "role",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
''';

      final contract = DeployedContract(
        ContractAbi.fromJson(contractAbi, "Auth"),
        EthereumAddress.fromHex(contractAddress),
      );
      /*final hashedPassword =
          bytesToHex(keccak256(utf8.encode(password)), include0x: false);*/
      EtherAmount balance = await client.getBalance(credentials.address);
      print("Solde: ${balance.getValueInUnit(EtherUnit.ether)} ETH");

      final function = contract.function("addItem");
      
      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [email, password, role],
        gasPrice: EtherAmount.inWei(BigInt.from(1000000000)), // 1 GWei
        maxGas: 300000,
      );

      // Envoyer la transaction
      await client.sendTransaction(
        credentials,
        transaction,
        chainId: 1337, // ID de Sepolia
      );
      bh(selectedRole);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inscription réussie et stockée sur la blockchain!"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint(
          'Erreur a lors de l\'inscription: $e'); // Afficher l'erreur complète dans la console
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'inscription: $e"),
        ),
      );
    }
  }*/

  Future<void> bh(String role) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (role == 'client') {
      int s = pref.getInt('client') ?? 1;
      s++;
      await pref.setInt('client', s);
    } else if (role == 'ouner') {
      int s = pref.getInt('ouner') ?? 1;
      s++;
      await pref.setInt('ouner', s);
    } else if (role == 'fabricant') {
      int s = pref.getInt('Fabricant') ?? 0;
      s++;
      await pref.setInt('Fabricant', s);
    } else if (role == 'fournisseur') {
      int s = pref.getInt('Fournisseur') ?? 0;
      s++;
      await pref.setInt('Fournisseur', s);
    } else if (role == 'transporteur') {
      int s = pref.getInt('Transporteur') ?? 0;
      s++;
      await pref.setInt('Transporteur', s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Créer un compte"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nomprenom,
              decoration: InputDecoration(
                labelText: " nom et prenom",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirmer le mot de passe",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: [
                "ouner",
                "fournisseur",
                "transporteur",
                "client",
                "fabricant"
              ]
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
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text) {
                  registerUser(
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text,
                      selectedRole,
                      nomprenom.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Les mots de passe ne correspondent pas!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "S'inscrire",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
