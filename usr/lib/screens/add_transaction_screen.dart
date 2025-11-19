import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'General';

  final List<String> _expenseCategories = [
    'General',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other'
  ];

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: enteredTitle,
      amount: enteredAmount,
      date: _selectedDate!,
      type: _selectedType,
      category: _selectedCategory,
    );

    Navigator.of(context).pop(newTx);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == TransactionType.expense;
    final categories = isExpense ? _expenseCategories : _incomeCategories;

    // Reset category if it's not in the current list (when switching types)
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Type Selector
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.money_off),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.attach_money),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = _selectedType == TransactionType.expense 
                        ? _expenseCategories.first 
                        : _incomeCategories.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Date Picker
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Choose Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
