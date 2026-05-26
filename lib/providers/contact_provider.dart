import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/contact_model.dart';
import '../data/repositories/contact_repository.dart';

class ContactNotifier extends StateNotifier<List<ContactModel>> {
  final ContactRepository _repo;

  ContactNotifier(this._repo) : super([]) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = await _repo.getAll();
  }

  Future<void> add(ContactModel contact) async {
    await _repo.add(contact);
    await loadAll();
  }

  Future<void> update(ContactModel contact) async {
    await _repo.update(contact);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<void> toggleFavorite(ContactModel contact) async {
    await _repo.toggleFavorite(contact.id!, !contact.isFavorite);
    await loadAll();
  }

  void clearAll() {
    state = [];
  }

  List<ContactModel> get favorites =>
      state.where((c) => c.isFavorite).toList();

  List<ContactModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }
}

final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => ContactRepository(),
);

final contactProvider =
    StateNotifierProvider<ContactNotifier, List<ContactModel>>(
  (ref) => ContactNotifier(ref.read(contactRepositoryProvider)),
);
