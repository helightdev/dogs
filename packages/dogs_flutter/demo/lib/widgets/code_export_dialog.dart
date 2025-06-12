import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class CodeExportDialog extends StatelessWidget {
  final String code;
  final String language;

  const CodeExportDialog({super.key, required this.code, this.language = "json"});

  @override
  Widget build(BuildContext context) {
    final rich = Highlighter(language: "json", theme: highlighterTheme).highlight(code);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText.rich(rich),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(onPressed: () {
        Navigator.of(context).pop();
      }, child: const Icon(Icons.close)),
    );
  }
}
