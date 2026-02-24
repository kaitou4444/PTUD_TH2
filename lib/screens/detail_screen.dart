import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

/// DetailScreen for creating/editing a note. Auto-saves on back.
class DetailScreen extends StatefulWidget {
  final Note? note;

  const DetailScreen({Key? key, this.note}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _editingNote;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _editingNote = widget.note!;
      _isNew = false;
    } else {
      final now = DateTime.now();
      _editingNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: '',
        content: '',
        createdAt: now,
        updatedAt: now,
      );
      _isNew = true;
    }
    _titleController = TextEditingController(text: _editingNote.title);
    _contentController = TextEditingController(text: _editingNote.content);
  }

  /// Save the note to provider (inserts or updates)
  Future<void> _saveNote() async {
    final provider = Provider.of<NoteProvider>(context, listen: false);
    final now = DateTime.now();
    final updated = Note(
      id: _editingNote.id,
      title: _titleController.text.trim(),
      content: _contentController.text,
      createdAt: _editingNote.createdAt,
      updatedAt: now,
    );
    await provider.upsertNote(updated);
  }

  Future<bool> _onWillPop() async {
    await _saveNote();
    return true;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await Provider.of<NoteProvider>(context, listen: false).deleteNote(_editingNote.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            if (!_isNew)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Viết ghi chú của bạn ở đây...',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
