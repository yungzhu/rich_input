import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RichInputController extends TextEditingController {
  final List<RichBlock> _blocks = [];
  RegExp _exp;

  RichInputController({String text}) : super(text: text);

  void addBlock(RichBlock block) {
    if (_blocks.indexWhere((element) => element.text == block.text) < 0) {
      _blocks.add(block);
      _exp = RegExp(_blocks.map((e) => e.text).join('|'));
    }
    text += block.text;
  }

  String get data {
    String str = text;
    _blocks.forEach((element) {
      str = str.replaceAll(element.text, element.data);
    });
    return str;
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    if (_exp == null) {
      return TextSpan(style: style, text: text);
    }
    if (text.isEmpty) {
      _blocks.clear();
    }

    final List<TextSpan> children = [];

    text.splitMapJoin(
      _exp,
      onMatch: (m) {
        final key = m[0];
        final RichBlock block = _blocks.firstWhere((element) {
          return element.text == key;
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

class RichBlock {
  final String text;
  final String data;
  final TextStyle style;

  const RichBlock({
    @required this.text,
    @required this.data,
    this.style = const TextStyle(color: Colors.blue),
  });
}

// class _RichInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     return newValue;
//   }
// }
