import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poem/providers/poem_provider.dart';
import 'package:poem/routes/app_router.dart';
import 'package:provider/provider.dart';

class AddPoemScreen extends StatefulWidget {
  const AddPoemScreen({super.key});

  @override
  State<AddPoemScreen> createState() => _AddPoemScreenState();
}

class _AddPoemScreenState extends State<AddPoemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _contentController.dispose();
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
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 32,
          top: provider.showsAppBar ? 5 : 32,
          right: 32,
          bottom: 32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNameField(provider.isLoading),
              const SizedBox(height: 20),
              _buildAuthorField(provider.isLoading),
              const SizedBox(height: 20),
              _buildContentField(provider.isLoading),
              const SizedBox(height: 32),
              if (provider.isError) _buildErrorDisplay(provider.error),
              if (provider.isError) const SizedBox(height: 20),
              Center(child: _buildSubmitButton(provider.isLoading)),
              const SizedBox(height: 16),
              Center(child: _buildResetButton(provider.isLoading)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(bool isLoading) {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '诗题',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入诗题';
        }
        return null;
      },
      enabled: !isLoading,
    );
  }

  Widget _buildAuthorField(bool isLoading) {
    return TextFormField(
      controller: _authorController,
      decoration: const InputDecoration(
        labelText: '作者',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入作者';
        }
        return null;
      },
      enabled: !isLoading,
    );
  }

  Widget _buildContentField(bool isLoading) {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: '名句',
        prefixIcon: Icon(Icons.import_contacts),
        border: OutlineInputBorder(),
      ),
      enabled: !isLoading,
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

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF238636),
        foregroundColor: Colors.white,
        fixedSize: Size.fromWidth(250),
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
                Text('正在创建...', style: TextStyle(fontSize: 16)),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.create),
                SizedBox(width: 8),
                Text('生成', style: TextStyle(fontSize: 16)),
              ],
            ),
    );
  }

  Widget _buildResetButton(bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading ? null : _resetForm,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF30363d)),
        foregroundColor: const Color(0xFFc9d1d9),
        fixedSize: Size.fromWidth(250),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.refresh), SizedBox(width: 8), Text('重置')],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    final poem = await context.read<PoemProvider>().createPoem(
      name: _nameController.text.trim(),
      author: _authorController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (poem != null && mounted) {
      context.pop();
    }
  }

  void _resetForm() {
    if (!mounted) return;

    _formKey.currentState?.reset();
    _nameController.clear();
    _authorController.clear();
    _contentController.clear();
    context.read<PoemProvider>().clearError();
  }
}
