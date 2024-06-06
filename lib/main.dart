import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_desktop_app/drift/database.dart';
import 'package:flutter_desktop_app/plain_sqlite/dto/sales.dart';
import 'package:flutter_desktop_app/plain_sqlite/migration/migration.dart';
import 'package:flutter_desktop_app/page/sales_detail.dart';
import 'package:flutter_desktop_app/plain_sqlite/provider/sales.dart';
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case MyHomePage.routeName:
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => MyHomePage(
                      title: "Segari POS",
                    ));
          case SalesDetailPage.routeName:
            return MaterialPageRoute(
                settings: settings,
                builder: (context) => SalesDetailPage(
                    settings.arguments as SalesDetailPageArguments));
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = "MyHomePage";
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _customerNameController = new TextEditingController();
  TextEditingController _itemController = new TextEditingController();
  TextEditingController _quantityController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  //List<SalesItem> items = [];
  List<OrderItem> items = [];
  List<Order> salesHistory = [];
  // final salesProvider = GetIt.I<SalesProvider>();
  final db = GetIt.I<AppDatabase>();

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
        items.add(OrderItem(
            id: -1,
            orderId: -1,
            name: _itemController.text,
            quantity: int.tryParse(_quantityController.text)!,
            price: double.tryParse(_priceController.text)!));
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
                      style: TextButton.styleFrom(padding: EdgeInsets.all(8)),
                      child: Text("Add Item"),
                    ),
                    TextButton(
                      onPressed: _insertToDb,
                      style: TextButton.styleFrom(padding: EdgeInsets.all(8)),
                      child: Text("End Sales"),
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
                          Text(items[int].name!),
                          Text("${items[int].quantity}x ${items[int].price}"),
                        ],
                      ),
                      Text("${items[int].quantity! * items[int].price!}"),
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
      return CircularProgressIndicator();
    } else {
      return ListView.builder(
        itemCount: salesHistory.length,
        itemBuilder: (context, int) {
          final salesElement = salesHistory[int] as Order;
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
