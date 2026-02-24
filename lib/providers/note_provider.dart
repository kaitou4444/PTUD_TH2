import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

/// NoteProvider uses ChangeNotifier to manage notes and search state.
class NoteProvider extends ChangeNotifier {
  final StorageService _storage;

  NoteProvider(this._storage);

  List<Note> _notes = [];
  String _searchQuery = '';
  bool _loaded = false;

  List<Note> get notes => _notes;

  /// Filtered notes by title (real-time)
  List<Note> get filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    final q = _searchQuery.toLowerCase();
    return _notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  bool get isLoaded => _loaded;

  /// Load notes from storage
  Future<void> loadNotes() async {
    _notes = await _storage.loadNotes();
    // Sort by updatedAt descending
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _loaded = true;
    notifyListeners();
  }

  /// Add or update a note
  Future<void> upsertNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.insert(0, note);
    }
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  /// Delete a note by id
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }
}
