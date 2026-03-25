import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedCategory;
  final List<String> _categories = ['Mechanical', 'Electronic', 'Software', 'Pribadi'];

  // Industry Standard Palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color bgSoft = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? 'Pribadi';
    
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan Deskripsi wajib diisi!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (widget.log == null) {
      widget.controller.addLog(
        title: _titleController.text,
        desc: _descController.text,
        authorId: widget.currentUser['uid'],
        teamId: widget.currentUser['teamId'],
        category: _selectedCategory,
        currentUser: widget.currentUser, // Pass current user
      );
    } else {
      widget.controller.updateLog(
        index: widget.index!,
        title: _titleController.text,
        desc: _descController.text,
        category: _selectedCategory,
        teamId: widget.currentUser['teamId'],
        currentUser: widget.currentUser, // Pass current user
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green.shade600;
      case 'Electronic': return Colors.blue.shade600;
      case 'Software': return Colors.orange.shade700;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgSoft,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          title: Text(
            widget.log == null ? 'Buat Log Baru' : 'Edit Laporan',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 28),
                onPressed: _save,
                tooltip: 'Simpan Laporan',
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'EDITOR', icon: Icon(Icons.edit_note_rounded)),
              Tab(text: 'PRATINJAU', icon: Icon(Icons.auto_awesome_mosaic_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEditorTab(),
            _buildPreviewTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel("Informasi Utama"),
          const SizedBox(height: 12),
          
          // Input Judul
          _buildTextField(
            controller: _titleController,
            label: "Judul Laporan",
            hint: "Contoh: Pemasangan Motor DC",
            icon: Icons.title_rounded,
          ),
          
          const SizedBox(height: 20),
          
          // Dropdown Kategori
          _buildCategoryDropdown(),
          
          const SizedBox(height: 30),
          _buildSectionLabel("Detail Progres (Markdown Support)"),
          const SizedBox(height: 12),
          
          // Input Deskripsi (Large)
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _descController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(height: 1.5),
              decoration: InputDecoration(
                hintText: 'Tuliskan detail pekerjaan Anda...\n\nGunakan # untuk judul\n* untuk poin-poin',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 100), // Spacing bawah agar tidak mepet
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Container(
      color: Colors.white,
      child: Markdown(
        data: _descController.text.isEmpty 
            ? "_Belum ada konten untuk dipratinjau..._" 
            : _descController.text,
        selectable: true,
        padding: const EdgeInsets.all(24),
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          p: const TextStyle(fontSize: 16, height: 1.6),
          listBullet: const TextStyle(color: primaryGreen, fontSize: 18),
        ),
      ),
    );
  }

  // --- Reusable UI Components ---

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.blueGrey.shade700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryGreen),
          labelStyle: const TextStyle(color: Colors.blueGrey),
          floatingLabelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryGreen),
        decoration: const InputDecoration(
          labelText: 'Kategori Laporan',
          prefixIcon: Icon(Icons.category_outlined, color: primaryGreen),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.blueGrey),
          floatingLabelStyle: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(category, style: const TextStyle(fontSize: 15)),
              ],
            ),
          );
        }).toList(),
        onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
      ),
    );
  }
}