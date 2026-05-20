import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _db;

  TransactionRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<List<TransactionModel>> getAll() => _db.getAllTransactions();

  Future<List<TransactionModel>> getRecent({int limit = 10}) =>
      _db.getRecentTransactions(limit: limit);

  Future<int> add(TransactionModel tx) => _db.insertTransaction(tx);

  Future<int> clearAll() => _db.deleteAllTransactions();

  Future<List<TransactionModel>> getByType(String type) async {
    final all = await _db.getAllTransactions();
    return all.where((t) => t.type == type).toList();
  }

  Future<List<TransactionModel>> search(String query) async {
    final all = await _db.getAllTransactions();
    final q = query.toLowerCase();
    return all.where((t) => t.merchant.toLowerCase().contains(q)).toList();
  }
}
