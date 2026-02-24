import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// StorageService handles saving/loading notes via SharedPreferences.
class StorageService {
  static const _notesKey = 'smart_note_notes';

  /// Load notes from SharedPreferences. Returns empty list if none.
  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return Note.listFromJson(jsonString);
    } catch (_) {
      return [];
    }
  }

  /// Persist the provided list of notes as JSON.
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = Note.listToJson(notes);
    await prefs.setString(_notesKey, jsonString);
  }

  /// Clear all notes (for debug/testing)
  Future<void> clearNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
  }
}
