import 'package:flutter/material.dart';
import 'package:flutter_desktop_app/drift/database.dart';
import 'package:flutter_desktop_app/sqflite/migration/migration.dart';
import 'package:flutter_desktop_app/page/sales_detail.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  //final db = await usePlainSqlite();
  final db = await useDrift();
  GetIt.I.registerSingleton<AppDatabase>(db);
  //GetIt.I.registerSingleton<SalesProvider>(SalesProvider()); // for plain sqlite
  runApp(const MyApp());
}

Future<Database> usePlainSqlite() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await openDatabase(
    "segari_pos.db",
    version: 3,
    onCreate: (Database db, int version) async {
      await db.execute('''
            create table sales(id integer primary key autoincrement, customer_name varchar not null, total double not null);
            create table sales_items(id integer primary key autoincrement, sales_id integer not null, name varchar not null, quantity integer not null, price double not null, foreign key(sales_id) references sales(id));
        ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      var batch = db.batch();
      executeMigration(batch, newVersion);
      await batch.commit();
    },
  );
  return db;
}

Future<AppDatabase> useDrift() async {
  final database = AppDatabase();
  return database;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case MyHomePage.routeName:
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => const MyHomePage(
                      title: "Segari POS",
                    ));
          case SalesDetailPage.routeName:
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => SalesDetailPage(
                    settings.arguments as SalesDetailPageArguments));
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = "MyHomePage";
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  //List<SalesItem> items = [];
  List<OrderProduct> items = [];
  List<Order> salesHistory = [];
  // final salesProvider = GetIt.I<SalesProvider>();
  final db = GetIt.I<AppDatabase>();

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Segari POS'),
            ),
            ListTile(
              title: const Text('POS'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sales History'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                _getSalesHistory();
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: generateBody(),
    );
  }

  Widget generateBody() {
    if (_selectedIndex == 0) {
      return _generatePOSPage();
    } else {
      return _generateHistoryPage();
    }
  }

  void _addItem() {
    if (_isInputValid()) {
      setState(() {
        // items.add(OrderProduct(
        //     id: -1,
        //     orderId: -1,
        //     quantity: int.tryParse(_quantityController.text)!,
        // ));
        _itemController.clear();
        _quantityController.clear();
        _priceController.clear();
      });
    }
  }

  bool _isInputValid() {
    return _itemController.text.isNotEmpty &&
        _itemController.text.isNotEmpty &&
        double.tryParse(_quantityController.text) != null &&
        double.tryParse(_priceController.text) != null;
  }

  void _insertToDb() async {
    final orderId = await db.ordersRepository.insert(OrdersCompanion.insert(customer: _customerNameController.text, total: _calculateTotal()));
    for (OrderItem salesItem in items) {
      db.orderItemsRepository.insert(OrderItemsCompanion.insert(
          name: salesItem.name,
          quantity: salesItem.quantity,
          price: salesItem.price,
          orderId: orderId));
    }
    // await salesProvider.insertSales(sales); // for using plain sqlite

    setState(() {
      _customerNameController.clear();
      _itemController.clear();
      _quantityController.clear();
      _priceController.clear();
      items = [];
    });
  }

  double _calculateTotal() {
    return items
        .map((e) => e.price * e.quantity)
        .reduce((total, curr) => total + curr);
  }

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  Widget _generatePOSPage() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                TextField(
                  maxLength: 30,
                  controller: _customerNameController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Customer Name",
                    labelStyle: TextStyle(color: Colors.green[800]),
                  ),
                ),
                TextField(
                  maxLength: 30,
                  controller: _itemController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Item Name",
                    labelStyle: TextStyle(color: Colors.green[800]),
                  ),
                ),
                TextFormField(
                  maxLength: 30,
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    labelStyle: TextStyle(color: Colors.green[800]),
                  ),
                ),
                TextFormField(
                  maxLength: 30,
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price",
                    labelStyle: TextStyle(color: Colors.green[800]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _addItem,
                      style: TextButton.styleFrom(padding: const EdgeInsets.all(8)),
                      child: const Text("Add Item"),
                    ),
                    TextButton(
                      onPressed: _insertToDb,
                      style: TextButton.styleFrom(padding: const EdgeInsets.all(8)),
                      child: const Text("End Sales"),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, int) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(items[int].name),
                          Text("${items[int].quantity}x ${items[int].price}"),
                        ],
                      ),
                      Text("${items[int].quantity * items[int].price}"),
                    ]);
              },
            ),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

  Widget _generateHistoryPage() {
    // using hive
    // final salesCollection = Hive.box("sales");
    // List<dynamic> sales = salesCollection.values.toList();

    // using sqflite
    if (salesHistory.isEmpty) {
      return const CircularProgressIndicator();
    } else {
      return ListView.builder(
        itemCount: salesHistory.length,
        itemBuilder: (context, int) {
          final salesElement = salesHistory[int];
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Customer Name: ${salesElement.customer}",
                textAlign: TextAlign.left,
              ),
              Text(
                "Total: ${salesElement.total}",
                textAlign: TextAlign.left,
              )
            ],
          );
        },
      );
    }
  }

  Future<void> _getSalesHistory() async {
    setState(() {
      salesHistory = [];
    });
    final results = await db.ordersRepository.getAll();
    setState(() {
      salesHistory = results;
    });
  }
}
