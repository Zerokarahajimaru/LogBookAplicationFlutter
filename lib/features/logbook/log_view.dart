import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/login_view.dart';
import 'package:flutter_application_1/features/logbook/log_controller.dart';
import 'package:flutter_application_1/features/logbook/log_editor_page.dart';
import 'package:flutter_application_1/features/logbook/widgets/log_item_widget.dart';
import 'package:flutter_application_1/features/logbook/log_preview_page.dart'; // Added
import 'models/log_model.dart';

class LogView extends StatefulWidget {
  final dynamic currentUser;
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color bgSoft = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    _controller.loadLogs(widget.currentUser['teamId']);
    _searchController.addListener(() => _controller.searchLog(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LogEditorPage(
        log: log, index: index, controller: _controller, currentUser: widget.currentUser
      ),
    ));
  }

  void _goToPreview(LogModel log) { // Added
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LogPreviewPage(log: log),
    ));
  }

  // --- Fungsi Konfirmasi Hapus (Standar Industri) ---
  void _showDeleteDialog(int index, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Hapus Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus laporan "$title"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              try {
                await _controller.removeLog(
                  index: index,
                  teamId: widget.currentUser['teamId'],
                  currentUser: widget.currentUser, // Pass current user
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan berhasil dihapus'), behavior: SnackBarBehavior.floating),
                );
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus laporan: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginView()), (r) => false);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color.fromRGBO(46, 125, 50, 1),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LogBook', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 23,color: Colors.white)),
                  Text('${widget.currentUser['username']}',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _controller.loadLogs(widget.currentUser['teamId'])),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _showLogoutDialog),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildIndustrialSearchBar(),
                _buildCategoryChips(),
              ],
            ),
          ),

          ValueListenableBuilder<List<LogModel>>(
            valueListenable: _controller.filteredLogsNotifier,
            builder: (context, logs, _) {
              if (logs.isEmpty) return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState());

              return SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = logs[index];
                      // The old isPublic check is removed. RBAC is now handled in the widget.

                      return LogItemWidget(
                        log: log,
                        currentUser: widget.currentUser, // Pass current user data
                        cardColor: _getCategoryColor(log.category),
                        onEdit: () => _goToEditor(log: log, index: index),
                        onDelete: () => _showDeleteDialog(index, log.title),
                        onPreview: () => _goToPreview(log), // Added
                      );
                    },
                    childCount: logs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        onPressed: () => _goToEditor(),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text("New Report", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildIndustrialSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari berdasarkan judul atau deskripsi...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: primaryGreen),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Semua', 'Mechanical', 'Electronic', 'Software', 'Pribadi'];
    return SizedBox(
      height: 55,
      child: ValueListenableBuilder<String>(
        valueListenable: _controller.selectedCategoryNotifier,
        builder: (context, selected, _) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selected == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => _controller.setCategoryFilter(cat),
                  selectedColor: primaryGreen.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? primaryGreen : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? primaryGreen : Colors.transparent)
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Laporan Belum Tersedia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Mulai buat log pertama untuk memantau progres tim.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green.shade600;
      case 'Electronic': return Colors.blue.shade600;
      case 'Software': return Colors.orange.shade700;
      default: return Colors.blueGrey;
    }
  }
}