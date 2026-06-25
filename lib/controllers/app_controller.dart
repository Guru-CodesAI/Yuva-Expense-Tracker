import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class AppController extends ChangeNotifier {
  static const String _expenseBoxName = 'expenses';
  static const String _settingsBoxName = 'settings';
  
  Box<Expense>? _expenseBox;
  Box? _settingsBox;

  double _monthlySalary = 0.0;
  List<Expense> _expenses = [];
  bool _isInitialized = false;
  String _userName = 'புதிய பயனர்';
  String _userEmail = 'yuva_user@gmail.com';
  String? _avatarPath;

  double get monthlySalary => _monthlySalary;
  List<Expense> get expenses => _expenses;
  bool get isInitialized => _isInitialized;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get avatarPath => _avatarPath;
  
  double get totalExpenses => _expenses.fold(0, (sum, item) => sum + item.amount);
  double get savings => _monthlySalary - totalExpenses;

  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    
    _expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    
    _monthlySalary = _settingsBox?.get('salary', defaultValue: 0.0) ?? 0.0;
    _userName = _settingsBox?.get('userName', defaultValue: 'புதிய பயனர்') ?? 'புதிய பயனர்';
    _userEmail = _settingsBox?.get('userEmail', defaultValue: 'yuva_user@gmail.com') ?? 'yuva_user@gmail.com';
    _avatarPath = _settingsBox?.get('avatarPath');
    _expenses = _expenseBox?.values.toList() ?? [];
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSalary(double amount) async {
    _monthlySalary = amount;
    await _settingsBox?.put('salary', amount);
    notifyListeners();
  }

  Future<void> setUserProfile(String name, String email, String? avatarPath) async {
    _userName = name;
    _userEmail = email;
    _avatarPath = avatarPath;
    await _settingsBox?.put('userName', name);
    await _settingsBox?.put('userEmail', email);
    await _settingsBox?.put('avatarPath', avatarPath);
    notifyListeners();
  }

  Future<void> addExpense(double amount, String category, DateTime date) async {
    final expense = Expense(amount: amount, category: category, date: date);
    await _expenseBox?.add(expense);
    _expenses = _expenseBox?.values.toList() ?? [];
    notifyListeners();
  }

  Future<void> updateExpense(int index, double amount, String category, DateTime date) async {
    final expense = Expense(amount: amount, category: category, date: date);
    await _expenseBox?.putAt(index, expense);
    _expenses = _expenseBox?.values.toList() ?? [];
    notifyListeners();
  }

  Future<void> deleteExpense(int index) async {
    await _expenseBox?.deleteAt(index);
    _expenses = _expenseBox?.values.toList() ?? [];
    notifyListeners();
  }

  static const List<String> tamilCategories = [
    'மளிகை',
    'மருந்து',
    'மின்சாரம்',
    'போக்குவரத்து',
    'உணவு',
    'மற்றவை',
  ];
}
