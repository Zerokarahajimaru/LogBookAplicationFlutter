import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPreview;
  final Color cardColor;
  final Map<String, dynamic> currentUser;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
    required this.cardColor,
    required this.currentUser,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} m lalu';
      }
      return '${difference.inHours} j lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} h lalu';
    } else {
      return DateFormat('d MMM y', 'id_ID').format(date);
    }
  }

  String _stripMarkdown(String text) {
    return text.replaceAll(RegExp(r'[#*_\-\[\]\(\)`>]'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    bool canEditOrDelete = false;
    final userRole = currentUser['role'] as String?;
    final userUid = currentUser['uid'] as String?;

    if (userRole == 'ketua') {
      canEditOrDelete = true;
    } else if (userRole == 'anggota' && log.authorId == userUid) {
      canEditOrDelete = true;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        elevation: 3,
        shadowColor: Colors.blueGrey.withAlpha(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 7,
                color: cardColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stripMarkdown(log.description),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cardColor.withAlpha(230),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 8),
                      child: Text(
                        _formatDate(DateTime.parse(log.date)),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.green, size: 20),
                          onPressed: onPreview,
                          tooltip: 'Preview',
                          visualDensity: VisualDensity.compact,
                        ),
                        if (canEditOrDelete) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: onDelete,
                            tooltip: 'Hapus',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
