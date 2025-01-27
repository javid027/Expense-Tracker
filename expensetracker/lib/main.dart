import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ExpenseProvider(),
    child: ExpenseTrackerApp(),
  ));
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpenseHomePage(),
    );
  }
}

class ExpenseProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _expenses = [];
  late Database _database;

  List<Map<String, dynamic>> get expenses => _expenses;

  ExpenseProvider() {
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'expenses.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, amount REAL, description TEXT, date TEXT)',
        );
      },
      version: 1,
    );
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final data = await _database.query('expenses');
    _expenses = data;
    notifyListeners();
  }

  Future<void> addExpense(double amount, String description) async {
    final newExpense = {
      'amount': amount,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    };
    await _database.insert('expenses', newExpense);
    _fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _database.delete('expenses', where: 'id = ?', whereArgs: [id]);
    _fetchExpenses();
  }

  Future<void> updateExpense(int id, double amount, String description) async {
    final updatedExpense = {
      'amount': amount,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    };
    await _database
        .update('expenses', updatedExpense, where: 'id = ?', whereArgs: [id]);
    _fetchExpenses();
  }
}

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _editingId;

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              final description = _descriptionController.text;

              if (amount != null && description.isNotEmpty) {
                if (_editingId == null) {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .addExpense(amount, description);
                } else {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .updateExpense(_editingId!, amount, description);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseDialog(
      BuildContext context, Map<String, dynamic> expense) {
    _amountController.text = expense['amount'].toString();
    _descriptionController.text = expense['description'];
    _editingId = expense['id'];

    debugPrint("amt:${expense['amount'].toString()}");
    debugPrint("description:${expense['description']}");
    debugPrint("id:${expense['id']}");
    _showAddExpenseDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _amountController.clear();
                _descriptionController.clear();
                _editingId = null;
                _showAddExpenseDialog(context);
              }),
        ],
      ),
      body: expenseProvider.expenses.isEmpty
          ? Center(
              child: Text(
                'No expenses added yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: expenseProvider.expenses.length,
              itemBuilder: (ctx, index) {
                final expense = expenseProvider.expenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: FittedBox(
                          child:
                              Text('\$${expense['amount'].toStringAsFixed(2)}'),
                        ),
                      ),
                    ),
                    title: Text(expense['description']),
                    subtitle: Text(DateFormat.yMMMd()
                        .format(DateTime.parse(expense['date']))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              _showEditExpenseDialog(context, expense),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            expenseProvider.deleteExpense(expense['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _amountController.clear();
            _descriptionController.clear();
            _editingId = null;
            _showAddExpenseDialog(context);
          }),
    );
  }
}
