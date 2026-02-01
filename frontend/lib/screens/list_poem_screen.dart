import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poem/models/poem.dart';
import 'package:poem/providers/poem_provider.dart';
import 'package:poem/routes/app_router.dart';
import 'package:poem/widgets/highlighted_text.dart';
import 'package:provider/provider.dart';

class ListPoemScreen extends StatefulWidget {
  const ListPoemScreen({super.key});

  @override
  State<ListPoemScreen> createState() => _ListPoemScreenState();
}

class _ListPoemScreenState extends State<ListPoemScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPoems();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Consumer<PoemProvider>(
        builder: (context, provider, child) {
          if (provider.allPoems.isEmpty) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.fetchPoems,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 20.0, 32.0, 16.0),
                child: _buildSearchBar(provider),
              ),
              Expanded(
                child: provider.poems.isEmpty
                    ? _buildEmptyView()
                    : _buildListView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(PoemProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜点什么吧...',
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _fetchPoems,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      iconSize: 15,
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _navigateToAddPoem,
          onLongPress: _toggleAppBar,
          icon: const Icon(Icons.add),
          label: const Text('添加'),
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.showsAppBar
                ? const Color(0xFF238636)
                : const Color(0xFF58a6ff),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '空空如也',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(PoemProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: provider.poems.length,
      itemBuilder: (context, index) {
        final poem = provider.poems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Dismissible(
            key: Key(poem.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _removePoem(poem),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 3,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    HighlightedText(
                      text: poem.name,
                      highlight: _searchController.text,
                      normalStyle: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    HighlightedText(
                      text: poem.author,
                      highlight: _searchController.text,
                      normalStyle: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: TextTheme.of(context).bodySmall!.color,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: poem.content != null
                  ? HighlightedText(
                      text: poem.content!,
                      highlight: _searchController.text,
                      normalStyle: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        height: 26 / 16.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigateToViewPoem(poem.id),
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      context.read<PoemProvider>().searchPoems(_searchController.text);
    });
  }

  void _fetchPoems() {
    context.read<PoemProvider>().fetchPoems();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<PoemProvider>().clearSearch();
  }

  void _removePoem(Poem poem) {
    context.read<PoemProvider>().removePoemById(poem.id);
  }

  void _navigateToAddPoem() {
    context.pushNamed(AppRoutes.addPoem);
  }

  void _toggleAppBar() {
    context.read<PoemProvider>().toggleAppBar();
  }

  void _navigateToViewPoem(int poemId) {
    context.pushNamed(
      AppRoutes.viewPoem,
      pathParameters: {'id': poemId.toString()},
    );
  }
}
