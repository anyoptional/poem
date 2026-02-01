import 'package:flutter/material.dart';
import 'package:poem/models/poem.dart';
import 'package:poem/services/poem_service.dart';

class PoemProvider with ChangeNotifier {
  final PoemService _poemService;

  List<Poem> _poems = [];
  List<Poem> _filteredPoems = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _showsAppBar = true;

  PoemProvider({PoemService? poemService})
    : _poemService = poemService ?? PoemService();

  List<Poem> get poems => _filteredPoems;

  List<Poem> get allPoems => _poems;

  bool get isLoading => _isLoading;

  bool get isError => _error != null;

  String get error => _error!;

  String get searchQuery => _searchQuery;

  bool get showsAppBar => _showsAppBar;

  Future<void> fetchPoems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _poemService.fetchPoems();
      _poems = response.data ?? [];
      _filteredPoems = _poems;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _poems = [];
      _filteredPoems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPoems(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPoems = _poems;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredPoems = _poems.where((poem) {
        return poem.name.toLowerCase().contains(lowerQuery) ||
            poem.author.toLowerCase().contains(lowerQuery) ||
            (poem.content?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredPoems = _poems;
    notifyListeners();
  }

  Future<Poem?> fetchPoemDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _poemService.fetchPoemById(id);
      _error = null;
      return response.data;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Poem?> createPoem({
    required String name,
    required String author,
    required String content,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _poemService.createPoem(
        name: name,
        author: author,
        content: content,
      );

      if (response.data != null) {
        _poems.insert(0, response.data!);
        searchPoems(_searchQuery); // Re-apply search filter
      }

      _error = null;
      return response.data;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> renewPoem(Poem poem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _poemService.renewPoem(poem);
      final poems = List<Poem>.from(_poems.where((e) => e.id == poem.id));
      _poems.removeWhere((e) => e.id == poem.id);
      _poems.insertAll(0, poems);

      final filteredPoems = List<Poem>.from(
        _filteredPoems.where((e) => e.id == poem.id),
      );
      _filteredPoems.removeWhere((e) => e.id == poem.id);
      _filteredPoems.insertAll(0, filteredPoems);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> removePoemById(int id) async {
    try {
      await _poemService.removePoemById(id);
      _poems.removeWhere((e) => e.id == id);
      _filteredPoems.removeWhere((e) => e.id == id);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void toggleAppBar() {
    _showsAppBar = !_showsAppBar;
    notifyListeners();
  }
}
