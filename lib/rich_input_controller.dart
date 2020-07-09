import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Expanded from TextEditingController,add insertBlock,insertText method and data property.
class RichInputController extends TextEditingController {
  final List<RichBlock> _blocks = [];
  RegExp _exp;

  RichInputController({String text}) : super(text: text);

  /// Insert a rich media [RichBlock] in the cursor position
  void insertBlock(RichBlock block) {
    if (_blocks.indexWhere((element) => element.text == block.text) < 0) {
      _blocks.add(block);
      _exp = RegExp(_blocks.map((e) => e._key).join('|'));
    }
    insertText(block._key);
  }

  @override
  void clear() {
    _blocks.clear();
    super.clear();
  }

  /// Insert text in the cursor position
  void insertText(String text) {
    final selection = value.selection;
    if (selection.baseOffset == -1) {
      this.text += text;
      return;
    } else {
      String str = selection.textBefore(this.text);
      str += text;
      str += selection.textAfter(this.text);

      value = value.copyWith(
        text: str,
        selection: selection.copyWith(
          baseOffset: selection.baseOffset + text.length,
          extentOffset: selection.baseOffset + text.length,
        ),
        composing: value.composing,
      );
    }
  }

  /// Get extended data information
  String get data {
    String str = text;
    _blocks.forEach((element) {
      str = str.replaceAll(element._key, element.data);
    });
    return str;
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    if (value.text.isEmpty) {
      _blocks.clear();
    }

    if (!value.composing.isValid || !withComposing) {
      return _getTextSpan(text, style);
    }

    final TextStyle composingStyle = style.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    return TextSpan(
      style: style,
      children: <TextSpan>[
        _getTextSpan(value.composing.textBefore(value.text), style),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(value.text),
        ),
        _getTextSpan(value.composing.textAfter(value.text), style),
      ],
    );
  }

  TextSpan _getTextSpan(String text, TextStyle style) {
    if (_exp == null) {
      return TextSpan(style: style, text: text);
    }

    final List<TextSpan> children = [];

    text.splitMapJoin(
      _exp,
      onMatch: (m) {
        final key = m[0];
        final RichBlock block = _blocks.firstWhere((element) {
          return element._key == key;
        }, orElse: () => null);
        if (block != null) {
          children.add(
            TextSpan(
              text: key,
              style: block.style,
            ),
          );
        }
        return key;
      },
      onNonMatch: (span) {
        if (span != "") {
          children.add(TextSpan(text: span, style: style));
        }
        return span;
      },
    );
    return TextSpan(style: style, children: children);
  }
}

/// Rich Media Data Blocks
class RichBlock {
  final String text;
  final String data;
  final TextStyle style;
  final String _key;

  const RichBlock({
    @required this.text,
    @required this.data,
    this.style = const TextStyle(color: Colors.blue),
  }) : _key = "$text\u200B";
}
