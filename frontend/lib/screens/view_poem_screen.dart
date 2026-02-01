import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poem/models/poem.dart';
import 'package:poem/providers/poem_provider.dart';
import 'package:poem/routes/app_router.dart';
import 'package:poem/screens/edit_poem_screen.dart';
import 'package:provider/provider.dart';

class ViewPoemScreen extends StatefulWidget {
  final int poemId;
  final Poem? poem;

  const ViewPoemScreen({super.key, required this.poemId, required this.poem});

  @override
  State<ViewPoemScreen> createState() => _ViewPoemScreenState();
}

class _ViewPoemScreenState extends State<ViewPoemScreen> {
  Poem? _poem;

  @override
  void initState() {
    super.initState();
    if (widget.poem == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPoemDetail();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PoemProvider>();
    return Scaffold(
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.isError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retry,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              Poem? poem = _getPoem();
              if (poem == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '空空如也',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return _buildContent(poem);
            },
          ),

          if (provider.showsAppBar)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: MediaQuery.of(context).padding.left + 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(Poem poem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            poem.name,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 1,
              height: 36 / 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            poem.author,
            style: TextStyle(fontSize: 16, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          if (poem.content != null && poem.content!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onLongPress: () => _showPoemEditor(PoemPart.content),
                  child: Text(
                    poem.content!,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 1,
                      height: 26 / 17.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          if (poem.note != null && poem.note!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '【注释】',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onLongPress: () => _showPoemEditor(PoemPart.note),
                  child: Text(
                    poem.note!,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.5,
                      height: 26 / 16.0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          if (poem.modernChinese != null && poem.modernChinese!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '【译文】',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onLongPress: () => _showPoemEditor(PoemPart.modernChinese),
                  child: Text(
                    poem.modernChinese!,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.5,
                      height: 26 / 16.0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          if (poem.comment != null && poem.comment!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '【赏析】',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onLongPress: () => _showPoemEditor(PoemPart.comment),
                  child: Text(
                    poem.comment!,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.5,
                      height: 26 / 16.0,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _fetchPoemDetail() async {
    if (!mounted) return;
    _poem = await context.read<PoemProvider>().fetchPoemDetail(widget.poemId);
  }

  void _retry() async {
    await _fetchPoemDetail();
  }

  void _showPoemEditor(PoemPart part) {
    if (!mounted) return;
    context.pushNamed(
      AppRoutes.editPoem,
      extra: {'poem': _getPoem(), 'part': part},
    );
  }

  Poem? _getPoem() {
    return widget.poem ?? _poem;
  }
}
