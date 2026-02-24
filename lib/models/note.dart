import 'dart:convert';

/// Note model with JSON serialization/deserialization.
class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Note from a Map (decoded JSON)
  factory Note.fromJson(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert Note to Map for encoding
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper: decode list of notes from JSON string
  static List<Note> listFromJson(String jsonString) {
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Helper: encode list of notes to JSON string
  static String listToJson(List<Note> notes) {
    final encoded = notes.map((e) => e.toJson()).toList();
    return json.encode(encoded);
  }
}
