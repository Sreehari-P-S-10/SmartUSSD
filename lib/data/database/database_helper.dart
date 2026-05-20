import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'tables.dart';
import '../models/transaction_model.dart';
import '../models/contact_model.dart';

class DatabaseHelper {
  static const _dbName = 'smartussd.db';
  static const _dbVersion = 1;

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createTransactionsTable);
    await db.execute(createContactsTable);
    await db.execute(createProfileTable);
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();

    // Seed transactions
    final transactions = [
      TransactionModel(
        merchant: 'ZESA Tokens',
        amount: 420,
        type: 'sent',
        timestamp: DateTime(now.year, now.month, now.day, 9, 14),
        reference: 'REF001',
        ussdCode: '*99*1*1#',
        iconKey: 'bolt',
      ),
      TransactionModel(
        merchant: 'Salary Credit',
        amount: 8500,
        type: 'received',
        timestamp: DateTime(now.year, now.month, now.day, 8, 0),
        reference: 'REF002',
        iconKey: 'work',
      ),
      TransactionModel(
        merchant: 'Netflix',
        amount: 199,
        type: 'sent',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        reference: 'REF003',
        ussdCode: '*99*1*1#',
        iconKey: 'movie',
      ),
      TransactionModel(
        merchant: 'Rahul',
        amount: 250,
        type: 'sent',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        reference: 'REF004',
        ussdCode: '*99*1*1#',
        iconKey: 'person',
      ),
      TransactionModel(
        merchant: 'Ananya',
        amount: 1000,
        type: 'received',
        timestamp: now.subtract(const Duration(days: 5)),
        reference: 'REF005',
        iconKey: 'person',
      ),
      TransactionModel(
        merchant: 'ATM Withdrawal',
        amount: 2000,
        type: 'failed',
        timestamp: now.subtract(const Duration(days: 6)),
        reference: 'REF006',
        iconKey: 'atm',
      ),
      TransactionModel(
        merchant: 'Amazon Pay',
        amount: 250,
        type: 'sent',
        timestamp: now.subtract(const Duration(hours: 2)),
        reference: 'REF007',
        ussdCode: '*99*1*1#',
        iconKey: 'shopping_bag',
      ),
    ];

    for (final tx in transactions) {
      await db.insert('transactions', tx.toMap());
    }

    // Seed contacts
    final contacts = [
      const ContactModel(name: 'Mother', phone: '+919447012345', isFavorite: true),
      const ContactModel(name: 'Rahul', phone: '+919876543210', isFavorite: true),
      const ContactModel(name: 'Ananya', phone: '+918765432109', isFavorite: true),
      const ContactModel(name: 'Vikram', phone: '+917654321098', isFavorite: true),
      const ContactModel(name: 'Priya', phone: '+916543210987', isFavorite: true),
      const ContactModel(name: 'Sarah', phone: '+917654321098', isFavorite: false),
      const ContactModel(name: 'College', phone: '+919999900000', isFavorite: false),
    ];

    for (final c in contacts) {
      await db.insert('contacts', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Seed default profile
    await db.insert('profile', {
      'id': 1,
      'name': 'Sreehari',
      'phone': '+91 98765 43210',
      'bank': 'Global Federal Bank',
      'is_verified': 1,
    });
  }

  // ─── Transactions ────────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'timestamp DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }

  // ─── Contacts ────────────────────────────────────────────────────────────────

  Future<List<ContactModel>> getAllContacts() async {
    final db = await database;
    final maps = await db.query('contacts', orderBy: 'name ASC');
    return maps.map((m) => ContactModel.fromMap(m)).toList();
  }

  Future<int> insertContact(ContactModel contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateContact(ContactModel contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'contacts',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Profile ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final maps = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> updateProfile(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('profile', data, where: 'id = ?', whereArgs: [1]);
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('contacts');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await db.close();
    _database = null;
    await deleteDatabase(path);
  }
}
