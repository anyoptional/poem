import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poem/models/poem.dart';
import 'package:poem/providers/poem_provider.dart';
import 'package:provider/provider.dart';

enum PoemPart { note, content, comment, modernChinese }

class EditPoemScreen extends StatefulWidget {
  final Poem poem;
  final PoemPart part;

  const EditPoemScreen({super.key, required this.poem, required this.part});

  @override
  State<EditPoemScreen> createState() => _EditPoemScreenState();
}

class _EditPoemScreenState extends State<EditPoemScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialTextOrNull());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PoemProvider>();
    return Scaffold(
      appBar: provider.showsAppBar
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                provider.isLoading
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        padding: const EdgeInsets.only(right: 12),
                        constraints: BoxConstraints.tightFor(
                          width: 24,
                          height: 24,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveUpdates,
                      ),
              ],
              actionsPadding: const EdgeInsets.only(right: 6),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.only(
          left: 16,
          top: provider.showsAppBar ? 0 : 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildTextView(provider)),
            if (!provider.showsAppBar) const SizedBox(height: 16),
            if (provider.isError) _buildErrorDisplay(provider.error),
            if (!provider.showsAppBar && provider.isError)
              const SizedBox(height: 20),
            if (!provider.showsAppBar)
              Center(child: _buildSaveButton(provider.isLoading)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextView(PoemProvider provider) {
    return TextField(
      controller: _controller,
      maxLines: null,
      expands: true,
      style: const TextStyle(fontSize: 18, letterSpacing: 1, height: 26 / 17.0),
      decoration: InputDecoration(
        hintText: '说点什么吧...',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF30363d)),
        ),
        contentPadding: const EdgeInsets.all(12.0),
      ),
      textAlignVertical: TextAlignVertical.top,
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF490202),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFf85149)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFf85149)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Color(0xFFf0f6fc)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _saveUpdates,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF238636),
        foregroundColor: Colors.white,
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('正在更新...', style: TextStyle(fontSize: 16)),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text('保存', style: TextStyle(fontSize: 16)),
              ],
            ),
    );
  }

  String? _initialTextOrNull() {
    if (widget.part == PoemPart.note) {
      return widget.poem.note;
    }

    if (widget.part == PoemPart.content) {
      return widget.poem.content;
    }

    if (widget.part == PoemPart.comment) {
      return widget.poem.comment;
    }

    if (widget.part == PoemPart.modernChinese) {
      return widget.poem.modernChinese;
    }

    return null;
  }

  Future<void> _saveUpdates() async {
    final Poem poem;
    final bool updated;
    switch (widget.part) {
      case PoemPart.note:
        updated = widget.poem.note != _controller.text;
        poem = widget.poem.copyWith(note: _controller.text);
        break;
      case PoemPart.content:
        updated = widget.poem.content != _controller.text;
        poem = widget.poem.copyWith(content: _controller.text);
        break;
      case PoemPart.comment:
        updated = widget.poem.comment != _controller.text;
        poem = widget.poem.copyWith(comment: _controller.text);
        break;
      case PoemPart.modernChinese:
        updated = widget.poem.modernChinese != _controller.text;
        poem = widget.poem.copyWith(modernChinese: _controller.text);
        break;
    }

    if (updated) {
      await context.read<PoemProvider>().renewPoem(poem);
    }
  }
}
