import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

/// Smart Note app entrypoint.
void main() {
  runApp(const SmartNoteApp());
}

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    return ChangeNotifierProvider(
      create: (_) => NoteProvider(storage),
      child: MaterialApp(
        title: 'Smart Note',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

