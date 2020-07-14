import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Expanded textfield support @someone #subjects with highlighting display.
class RichInput extends TextField {
  RichInput({
    Key key,
    RichInputController controller,
    FocusNode focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextInputType keyboardType,
    TextInputAction textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle style,
    StrutStyle strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical,
    TextDirection textDirection,
    bool readOnly = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    bool maxLengthEnforced = true,
    void Function(String) onChanged,
    void Function() onEditingComplete,
    void Function(String) onSubmitted,
    // List<TextInputFormatter> inputFormatters,
    bool enabled,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool enableInteractiveSelection = true,
    void Function() onTap,
    Widget Function(BuildContext,
            {int currentLength, bool isFocused, int maxLength})
        buildCounter,
    ScrollController scrollController,
    ScrollPhysics scrollPhysics,
  }) : super(
          controller: controller,
          key: key,
          focusNode: focusNode,
          decoration: decoration,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          textDirection: textDirection,
          readOnly: readOnly,
          toolbarOptions: toolbarOptions,
          showCursor: showCursor,
          autofocus: autofocus,
          obscureText: obscureText,
          autocorrect: autocorrect,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          enableSuggestions: enableSuggestions,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          maxLengthEnforced: maxLengthEnforced,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          inputFormatters: [_RichInputFormat(controller)],
          enabled: enabled,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorColor: cursorColor,
          selectionHeightStyle: selectionHeightStyle,
          selectionWidthStyle: selectionWidthStyle,
          keyboardAppearance: keyboardAppearance,
          scrollPadding: scrollPadding,
          dragStartBehavior: dragStartBehavior,
          enableInteractiveSelection: enableInteractiveSelection,
          onTap: onTap,
          buildCounter: buildCounter,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
        );
}

/// Expanded from TextEditingController,add insertBlock,insertText method and data property.
class RichInputController extends TextEditingController {
  final List<RichBlock> _blocks = [];
  RegExp _exp;

  RichInputController({String text}) : super(text: text);

  /// Insert a rich media [RichBlock] in the cursor position
  void insertBlock(RichBlock block) {
    if (_blocks.indexWhere((element) => element.text == block.text) < 0) {
      _blocks.add(block);
      _exp = RegExp(_blocks.map((e) => RegExp.escape(e._key)).join('|'));
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
      final String str = this.text + text;
      value = value.copyWith(
        text: str,
        selection: selection.copyWith(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
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

const _specialChar = "\u200B";

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
  }) : _key = "$text$_specialChar";
}

class _RichInputFormat implements TextInputFormatter {
  final RichInputController controller;

  const _RichInputFormat(this.controller);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final delLength = oldText.length - newValue.text.length;
    String char;
    int offset;
    if (delLength == 1) {
      char = oldText.substring(
          newValue.selection.baseOffset, newValue.selection.baseOffset + 1);
      offset = newValue.selection.baseOffset;
    } else if (delLength == 2) {
      // two characters will be deleted on huawei
      char = oldText.substring(
          newValue.selection.baseOffset + 1, newValue.selection.baseOffset + 2);
      offset = newValue.selection.baseOffset + 1;
    }

    if (char == _specialChar) {
      final newText = newValue.text;
      final oldStr = oldText.substring(0, offset);
      final delStr = "$oldStr{#del#}";
      String str = delStr;
      controller._blocks.forEach((element) {
        str = str.replaceFirst("${element.text}{#del#}", "");
      });
      if (str != delStr && str != oldStr) {
        str += newValue.selection.textInside(newText) +
            newValue.selection.textAfter(newText);

        final len = newText.length - str.length;
        return newValue.copyWith(
          text: str,
          selection: newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset - len,
            extentOffset: newValue.selection.baseOffset - len,
          ),
        );
      }
    }
    return newValue;
  }
}
