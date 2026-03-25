import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/logbook/models/log_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class LogPreviewPage extends StatelessWidget {
  final LogModel log;

  const LogPreviewPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(log.title),
        backgroundColor: const Color.fromRGBO(46, 125, 50, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${log.category}',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('d MMM y, HH:mm', 'id_ID').format(DateTime.parse(log.date))}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const Divider(height: 32),
            MarkdownBody(
              data: log.description,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16),
                h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  backgroundColor: Colors.black12,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: const Border(
                    left: BorderSide(
                      color: Colors.grey,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
