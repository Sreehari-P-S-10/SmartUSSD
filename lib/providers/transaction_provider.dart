import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repo;

  TransactionNotifier(this._repo) : super([]) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = await _repo.getAll();
  }

  Future<void> add(TransactionModel tx) async {
    await _repo.add(tx);
    await loadAll();
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    state = [];
  }

  List<TransactionModel> filter({
    String? type,
    String? query,
  }) {
    return state.where((tx) {
      final matchesType = type == null || type == 'all' || tx.type == type;
      final matchesQuery = query == null ||
          query.isEmpty ||
          tx.merchant.toLowerCase().contains(query.toLowerCase());
      return matchesType && matchesQuery;
    }).toList();
  }

  List<TransactionModel> getRecent({int limit = 10}) {
    final sorted = [...state]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  TransactionModel? getLastTransaction() {
    if (state.isEmpty) return null;
    final sorted = [...state]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first;
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  (ref) => TransactionNotifier(ref.read(transactionRepositoryProvider)),
);
