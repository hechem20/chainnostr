import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:suiviedeschaine/produit/ajoutproduit.dart';
import 'package:suiviedeschaine/produit/produit2.dart' show Produit2;
/*import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';*/
import 'package:shared_preferences/shared_preferences.dart';

class ProduitListPage extends StatefulWidget {
  final String userRole;
  final String? ide;
  final String? nom;

  ProduitListPage(
      {required this.userRole,
      required this.ide,
      required this.nom}); // ✅ Ajout de key

  @override
  _ProduitListPageState createState() => _ProduitListPageState();
}

/*class _ProduitListPageState extends State<ProduitListPage> {
  late Web3Client _client;
  late String v;
  late String selectedRole;
  final String rpcUrl = "HTTP://127.0.0.1:7545";
  final String contractAddress = "0x619cf02D2b7a9900a3bA3b1d7D43958a0A759cb6";
  final String privateKey =
      "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a";
  List<Map<String, dynamic>> _products = [];
  //List<Map<String, dynamic>> p = [];
  late bool canEdit;
  late String abi;
  Future<List<Map<String, dynamic>>>? _productFuture;
  TextEditingController _searchController = TextEditingController();

  // final  contract;
  @override
  void initState() {
    super.initState();
    _productFuture = _initializeWeb3();
  }

  Future<List<Map<String, dynamic>>> _initializeWeb3() async {
    _client = Web3Client(rpcUrl, Client());

    abi = """
""";
    final contractAbi = ContractAbi.fromJson(abi, "SupplyChain");

    final contract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(contractAddress),
    );

    final function = contract.function('getAllProductIds');
    final result = await _client.call(
      contract: contract,
      function: function,
      params: [],
    );
    List productIds = (result[0] as List).map((e) => e.toString()).toList();
    print(productIds);
    List<Map<String, dynamic>> fetchedProducts = [];

    for (String id in productIds) {
      final function = contract.function("getProduct");

      final product = await _client.call(
        contract: contract,
        function: function,
        params: [id],
      );
      print(product[2]);
      if (product != null) {
        fetchedProducts.add({
          'id': product[0]?.toString() ?? "ID inconnu",
          'description': product[1]?.toString() ?? "Description indisponible",
          'status': product[2]?.toString() ?? "Indisponible",
          'price': BigInt.tryParse(product[3]?.toString() ?? "0"),
          'qte': BigInt.tryParse(product[4]?.toString() ?? "0"),
          'img': product[5]?.toString() ?? "ID inconnu",
          'createdAt':
              BigInt.tryParse(product[6]?.toString() ?? "0") ?? BigInt.zero,
          'updatedAt':
              BigInt.tryParse(product[7]?.toString() ?? "0") ?? BigInt.zero,
        });
      }
      setState(() {
        print(fetchedProducts);
        _products = fetchedProducts.cast<Map<String, dynamic>>();
      });
    }
    return _products;
  }

  // ✅ Fonction pour mettre à jour un produit
  Future<void> _updateProduct(
      String id,
      String newDescription,
      BigInt? newPrice,
      BigInt? qte,
      String img,
      String selectedrole,
      String abi) async {
    /* String abi =
        await DefaultAssetBundle.of(context).loadString("assets/abi.json");*/
    final contractAbi = ContractAbi.fromJson(abi, "SupplyChain");

    final contract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(contractAddress),
    );

    final updateProductFunction = contract.function("updateProduct");

    /*  EthereumAddress currentUserouner =
        EthereumAddress.fromHex('0xebD086C03Bc878BA41f7dfc310470b21f201Ca4a');

    EthereumAddress currentUserfournisseur =
        EthereumAddress.fromHex("0x15101484f3c58458E77a959c2d8d3D4a26F33805");

    EthereumAddress currentUserclient =
        EthereumAddress.fromHex("0x2C60405345037e65E18AC2afAf66E0a7eDaB795C");

    EthereumAddress currentUserfabricant =
        EthereumAddress.fromHex('0xebD086C03Bc878BA41f7dfc310470b21f201Ca4a');

    EthereumAddress currentUsertransporteur =
        EthereumAddress.fromHex("0x15101484f3c58458E77a959c2d8d3D4a26F33805");*/

    final credentials = EthPrivateKey.fromHex(privateKey);

    try {
      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: updateProductFunction,
          parameters: [id, newDescription, newPrice, qte, img, selectedrole],
          //gasPrice: EtherAmount.inWei(BigInt.from(1000000000)), // 1 Gwei
          //maxGas: 300000,
        ),
        chainId: 1337,
      );
      print("Produit mis à jour avec succès.");
      _initializeWeb3();
    } catch (e) {
      print("Erreur lors de la mise à jour : $e");
    }
  }

  // ✅ Fonction pour supprimer un produit (uniquement Fabricant)
  Future<void> _deleteProduct(String id, String abi) async {
    /*if (widget.userRole != "fabricant") {
      print("Seul le fabricant peut supprimer un produit.");
      return;
    }*/

    final contractAbi = ContractAbi.fromJson(abi, "SupplyChain");

    final contract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(contractAddress),
    );

    final deleteProductFunction = contract.function("deleteProduct");

    final credentials = EthPrivateKey.fromHex(privateKey);

    try {
      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: deleteProductFunction,
          parameters: [id],
          //gasPrice: EtherAmount.inWei(BigInt.from(1000000000)), // 1 Gwei
          //maxGas: 300000,
        ),
        chainId: 1337,
      );
      print("Produit supprimé avec succès.");
      _initializeWeb3();
    } catch (e) {
      print("Erreur lors de la suppression : $e");
    }
  }

  /// 🔥 **Récupérer les détails d'un produit**
  /*Future<List?> getProduct(String id, final contract) async {
    final function = contract.function("getProduct");
    final result = await _client.call(
      contract: contract,
      function: function,
      params: [id],
    );
    return result;
  }*/
  List<Map<String, dynamic>> getProductById(String id) {
    List<Map<String, dynamic>> product = [];
    for (int i = 0; i < _products.length; i++) {
      if (_products[i]["id"] == id) {
        product.add({
          'id': _products[i]["id"]?.toString() ?? "ID inconnu",
          'description': _products[i]["description"]?.toString() ??
              "Description indisponible",
          'status': _products[i]["status"]?.toString() ?? "Indisponible",
          'price': BigInt.tryParse(_products[i]["price"]?.toString() ?? "0"),
          'qte': BigInt.tryParse(_products[i]["qte"]?.toString() ?? "0"),
          'img': _products[i]["img"]?.toString() ?? "inconnue",
        }); // Si l'id correspond, retourne le produit
      }
      print(product);
    }
    return product;
  }

  void _searchProduct(String searchTerm, String abi) async {
    final contractAbi = ContractAbi.fromJson(abi, "SupplyChain");

    final contract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(contractAddress),
    );
    final function = contract.function("rechercherProduit");
    final searchResults = await _client.call(
      contract: contract,
      function: function,
      params: [searchTerm],
    );
    print(searchResults);
    List items = ["Cree", "Stock", "Expedie", "Livre", "Recu"];
    List<Map<String, dynamic>> products = [];
    for (var product in searchResults.first) {
      products.add({
        'id': product[0]?.toString() ?? "ID inconnu",
        'description': product[1]?.toString() ?? "Description indisponible",
        'status': items[int.parse(product[2].toString())],
        'price': BigInt.tryParse(product[3]?.toString() ?? "0"),
        'qte': BigInt.tryParse(product[4]?.toString() ?? "0"),
        'img': product[5]?.toString() ?? "inconnu",
        'createdAt':
            BigInt.tryParse(product[6]?.toString() ?? "0") ?? BigInt.zero,
        'updatedAt':
            BigInt.tryParse(product[7]?.toString() ?? "0") ?? BigInt.zero,
      });
    }

    setState(() {
      print(products);
      _productFuture = Future.value(products);
    });
  }

  Future<void> countProductStatus(List<dynamic> productFuture) async {
    int v = 0, y = 0, x = 0, k = 0;

    for (var product in productFuture) {
      String? status = product['status'];

      if (status == 'Cree') {
        v++;
      }
      if (status == 'Stock') {
        y++;
      }
      if (status == 'Expedie') {
        x++;
      }
      if (status == 'Recu') {
        k++;
      }
    }

    // Stocker les résultats dans SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cree', v);
    await prefs.setInt('stock', y);
    await prefs.setInt('expedie', x);
    await prefs.setInt('recu', k);
    print(prefs.getInt('stock'));
  }*/
class _ProduitListPageState extends State<ProduitListPage> {
  List<Map<String, dynamic>> _products = [];
  Future<List<Map<String, dynamic>>>? _productFuture;
  TextEditingController _searchController = TextEditingController();
  late String selectedRole;
  late String v;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProductsFromDb();
  }

  Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'produit.db'),
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchProductsFromDb() async {
    final db = await _getDatabase();
    final products = await db.query('produits');
    setState(() {
      _products = products;
    });
    return products;
  }

  Future<void> _updateProduct(String id, String? newDescription,
      BigInt? newPrice, BigInt? qte, String? img, String? v) async {
    final db = await _getDatabase();
    await db.update(
      'produits',
      {
        'description': newDescription,
        'price': newPrice?.toInt() ?? 0,
        'qte': qte?.toInt() ?? 0,
        'status': v ?? '',
        'img': img ?? '',
        //'updatedAt': DateTime.now().millisecondsSinceEpoch
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _productFuture = _fetchProductsFromDb();
  }

  Future<void> _deleteProduct(String id) async {
    final db = await _getDatabase();
    await db.delete('produits', where: 'id = ?', whereArgs: [id]);
    _productFuture = _fetchProductsFromDb();
  }

  List<Map<String, dynamic>> getProductById(String id) {
    return _products.where((p) => p["id"] == id).toList();
  }

  void _searchProduct(String searchTerm) async {
    final db = await _getDatabase();
    final products = await db.query(
      'produits',
      where: 'description LIKE ?',
      whereArgs: ['%$searchTerm%'],
    );
    setState(() {
      _productFuture = Future.value(products);
    });
  }

  Future<void> countProductStatus(List<dynamic> productFuture) async {
    int v = 0, y = 0, x = 0, k = 0;
    for (var product in productFuture) {
      String? status = product['status'];
      if (status == 'Cree') v++;
      if (status == 'Stock') y++;
      if (status == 'Expedie') x++;
      if (status == 'Recu') k++;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cree', v);
    await prefs.setInt('stock', y);
    await prefs.setInt('expedie', x);
    await prefs.setInt('recu', k);
  }

  // UI identique : tu peux garder le reste du code (ListView, boutons, _showUpdateDialog etc.)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Rechercher un produit...",
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _searchProduct(_searchController.text);
                  }
                },
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return Center(child: Text("Aucun produit trouvé"));
            }
            List<dynamic> products = snapshot.data!;

            countProductStatus(products);
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                selectedRole = products[index]["status"];
                //print("Image URL: ${products[index]["img"]}");

                bool canEdit = widget.userRole == "ouner" ||
                    (widget.userRole == "fabricant" &&
                        products[index]["status"] == "Cree") ||
                    (widget.userRole == "fournisseur" &&
                        products[index]["status"] == "Stock") ||
                    (widget.userRole == "transporteur" &&
                        products[index]["status"] == "Livre") ||
                    (widget.userRole == "client" &&
                        products[index]["status"] == "Recu");
                bool pro = (widget.userRole == "client" &&
                    products[index]["status"] == "Stock");
                return Card(
                  child: ListTile(
                    title: Text(products[index]["description"] ??
                        "Description indisponible"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Prix: ${products[index]["price"] ?? "Inconnu"} ETH"),
                        Text(
                            "Status: ${products[index]["status"] ?? "Indisponible"}"),
                        Text(
                            "Quantité: ${products[index]["qte"] ?? "Indisponible"}"),
                        SizedBox(height: 8),
                        products[index]["img"] != null &&
                                products[index]["img"] != ""
                            ? Image.network(
                                products[index]["img"],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text("Image non disponible"),
                              )
                            : Text("Image: Indisponible"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canEdit)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showUpdateDialog(
                                  products[index]["id"],
                                  products[index]["description"],
                                  products[index]["price"] != null
                                      ? BigInt.parse(
                                          products[index]["price"].toString())
                                      : BigInt.zero,
                                  products[index]["qte"] != null
                                      ? BigInt.parse(
                                          products[index]["qte"].toString())
                                      : BigInt.zero,
                                  products[index]["img"]);
                            },
                          ),
                        if (canEdit)
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              print(products[index]["id"]);
                              _deleteProduct(products[index]["id"]);
                            },
                          ),
                        if (pro)
                          IconButton(
                            icon: Icon(Icons.shopping_cart,
                                color: const Color.fromARGB(255, 124, 244, 54)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Produit2(
                                        products: getProductById(
                                            products[index]["id"]),
                                        ide: widget.ide ?? '',
                                        nom: widget.nom ?? '')),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Afficher un formulaire pour ajouter un fabricant
            if (widget.userRole == "ouner" || widget.userRole == "fabricant") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutProduit()),
              );
            }
          },
          child: Icon(Icons.add),
          tooltip: 'Ajouter un produit',
        ));
  }

  // ✅ Boîte de dialogue pour modifier un produit
  void _showUpdateDialog(String id, String currentDescription,
      BigInt currentPrice, BigInt currentqte, String? currentimg) {
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);
    TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());
    TextEditingController qte =
        TextEditingController(text: currentqte.toString());
    TextEditingController img = TextEditingController(text: currentimg ?? '');
    v = selectedRole;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier Produit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Nouvelle Description"),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Nouveau Prix (ETH)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: qte,
                decoration: InputDecoration(labelText: "Nouveau qte (ETH)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: img,
                decoration:
                    InputDecoration(labelText: "URL ou hash de l'image"),
              ),
              SizedBox(height: 20),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole, //Cree,stock ,Expedie, Livre, Recu

                items: ["Cree", "Stock", "Expedie", "Livre", "Recu"]
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                    v = selectedRole;
                  });
                },

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: "Sélectionnez votre rôle",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProduct(
                    id,
                    descriptionController.text,
                    BigInt.from(int.parse(priceController.text)),
                    BigInt.from(int.parse(qte.text)),
                    img.text,
                    v);
                Navigator.pop(context);
              },
              child: Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }
}
