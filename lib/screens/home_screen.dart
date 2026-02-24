import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'detail_screen.dart';

/// HomeScreen: displays notes in a 2-column masonry grid with search and FAB.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _startedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_startedLoad) {
      _startedLoad = true;
      // Load notes when home screen is shown
      final provider = Provider.of<NoteProvider>(context, listen: false);
      provider.loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Note - Đồng Phúc Quân - 1951060938'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => Provider.of<NoteProvider>(context, listen: false).setSearchQuery(v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm kiếm theo tiêu đề',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<NoteProvider>(
                builder: (context, provider, _) {
                  if (!provider.isLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = provider.filteredNotes;
                  if (notes.isEmpty) {
                    // Empty state
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note, size: 120, color: Colors.black12),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa có ghi chú nào, hãy tạo mới nhé!',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Dismissible(
                          key: ValueKey(note.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (dir) async {
                            final keep = await showDialog<bool>(
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
                            if (keep == true) {
                              await Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id);
                              return true;
                            }
                            return false;
                          },
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: NoteCard(
                            note: note,
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(note: note)));
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DetailScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
