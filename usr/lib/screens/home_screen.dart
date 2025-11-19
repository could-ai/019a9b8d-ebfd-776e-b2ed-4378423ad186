import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'Grocery Shopping',
      amount: 69.99,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
      category: 'Food',
    ),
    Transaction(
      id: 't2',
      title: 'Monthly Salary',
      amount: 3000.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.income,
      category: 'Salary',
    ),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  double get _totalBalance {
    double income = _userTransactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    double expense = _userTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return income - expense;
  }

  double get _totalIncome {
    return _userTransactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _userTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void _addNewTransaction(Transaction newTx) {
    setState(() {
      _userTransactions.insert(0, newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _startAddNewTransaction(BuildContext context) async {
    final result = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );

    if (result != null) {
      _addNewTransaction(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Finances'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormat.format(_totalBalance),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Income', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                          Text(
                            currencyFormat.format(_totalIncome),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey.shade300),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text('Expense', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          Text(
                            currencyFormat.format(_totalExpense),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          
          // Transactions List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _userTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _userTransactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _userTransactions[index];
                      return Dismissible(
                        key: ValueKey(tx.id),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteTransaction(tx.id);
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: tx.type == TransactionType.income
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: FittedBox(
                                  child: Icon(
                                    tx.type == TransactionType.income
                                        ? Icons.attach_money
                                        : Icons.money_off,
                                    color: tx.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              tx.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              '${DateFormat.yMMMd().format(tx.date)} • ${tx.category}',
                            ),
                            trailing: Text(
                              '${tx.type == TransactionType.income ? '+' : '-'} ${currencyFormat.format(tx.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: tx.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
