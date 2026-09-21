import 'package:flutter/services.dart';

abstract interface class ClipboardWriter {
  Future<void> writeText(String text);
}

class FlutterClipboardWriter implements ClipboardWriter {
  const FlutterClipboardWriter();

  @override
  Future<void> writeText(String text) => Clipboard.setData(ClipboardData(text: text));
}
