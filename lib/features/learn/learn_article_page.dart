import 'package:flutter/material.dart';

import 'package:dranyen/features/learn/learn_content.dart';

const _amber = Color(0xFFF0A93C);
const _ink = Color(0xFFE8EAED);
const _body = Color(0xFFC4C8D0);
const _muted = Color(0xFF9AA0AB);

class LearnArticlePage extends StatelessWidget {
  final Article article;
  const LearnArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [for (final b in article.blocks) _block(b)],
      ),
    );
  }

  Widget _block(Block b) {
    return switch (b) {
      H(:final text) => Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Text(text, style: const TextStyle(color: _amber, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      P(:final text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(text, style: const TextStyle(color: _body, fontSize: 15.5, height: 1.55)),
        ),
      Bul(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7, right: 10),
                        child: Icon(Icons.circle, size: 5, color: _amber),
                      ),
                      Expanded(child: Text(it, style: const TextStyle(color: _body, fontSize: 15, height: 1.5))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      Quote(:final text, :final attribution) => Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: _amber.withValues(alpha: 0.6), width: 3)),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(color: _ink, fontSize: 16, height: 1.6, fontStyle: FontStyle.italic)),
              if (attribution != null) ...[
                const SizedBox(height: 8),
                Text('— $attribution', style: const TextStyle(color: _muted, fontSize: 12.5)),
              ],
            ],
          ),
        ),
      // Flex columns + wrapping text, so the table always fits the screen
      // width — never scrolls sideways, never overruns.
      Tbl(:final headers, :final rows) => Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 16),
          child: Table(
            columnWidths: {for (var i = 0; i < headers.length; i++) i: const FlexColumnWidth()},
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: _amber.withValues(alpha: 0.08)),
                children: [for (final h in headers) _cell(h, header: true)],
              ),
              for (final r in rows)
                TableRow(children: [for (final c in r) _cell(c)]),
            ],
          ),
        ),
      Note(:final text) => Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Text(text, style: const TextStyle(color: _muted, fontSize: 12.5, height: 1.5)),
        ),
    };
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: header ? _amber : _body,
          fontSize: header ? 11.5 : 12,
          height: 1.3,
          fontWeight: header ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
