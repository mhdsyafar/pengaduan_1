import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugErrorView extends StatelessWidget {
  final Object error;
  final StackTrace stack;

  const DebugErrorView({
    super.key,
    required this.error,
    required this.stack,
  });

  @override
  Widget build(BuildContext context) {
    final text = '''
========= FLUTTER ERROR =========

$error

========= STACK TRACE =========

$stack
''';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("DEBUG ERROR"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error copied to clipboard ✅"),
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            text,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}