import '../database/database_helper.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final DatabaseHelper _db;

  ContactRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<List<ContactModel>> getAll() => _db.getAllContacts();

  Future<List<ContactModel>> getFavorites() async {
    final all = await _db.getAllContacts();
    return all.where((c) => c.isFavorite).toList();
  }

  Future<int> add(ContactModel contact) => _db.insertContact(contact);

  Future<int> update(ContactModel contact) => _db.updateContact(contact);

  Future<int> delete(int id) => _db.deleteContact(id);

  Future<int> toggleFavorite(int id, bool isFavorite) =>
      _db.toggleFavorite(id, isFavorite);

  Future<List<ContactModel>> search(String query) async {
    final all = await _db.getAllContacts();
    final q = query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q))
        .toList();
  }
}
