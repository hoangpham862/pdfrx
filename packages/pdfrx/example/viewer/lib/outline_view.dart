//
// Just a rough implementation of the document index
//
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Class thay thế cho Record trong Dart 3.0 để tương thích với Dart 2.19
class _OutlineEntry {
  _OutlineEntry(this.node, this.level);
  final PdfOutlineNode node;
  final int level;
}

class OutlineView extends StatelessWidget {
  const OutlineView({required this.outline, required this.controller, super.key});

  final List<PdfOutlineNode>? outline;
  final PdfViewerController controller;

  @override
  Widget build(BuildContext context) {
    // Chuyển iterable thành list các đối tượng _OutlineEntry
    final list = _getOutlineList(outline, 0).toList();
    return SizedBox(
      width: list.isEmpty ? 0 : 200,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return InkWell(
            onTap: () => controller.goToDest(item.node.dest),
            child: Container(
              margin: EdgeInsets.only(left: item.level * 16.0 + 8, top: 8, bottom: 8),
              child: Text(item.node.title, softWrap: false),
            ),
          );
        },
      ),
    );
  }

  /// Hàm đệ quy tạo danh sách outline với level thụt đầu dòng
  Iterable<_OutlineEntry> _getOutlineList(List<PdfOutlineNode>? outline, int level) sync* {
    if (outline == null) return;
    for (final node in outline) {
      yield _OutlineEntry(node, level);
      yield* _getOutlineList(node.children, level + 1);
    }
  }
}
