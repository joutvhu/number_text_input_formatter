import 'package:flutter/widgets.dart';

abstract class TextValueEditor {
  factory TextValueEditor(TextEditingValue inputValue) => DefaultTextValueEditor(inputValue);

  List<int> get codeUnits;

  int operator [](int index);

  int get length;

  String get text;

  TextEditingValue get inputValue;

  MutableTextRange? get selection;

  MutableTextRange? get composingRegion;

  String? at(int index);

  prefix(String value);

  suffix(String value);

  insert(int index, String value);

  replace(int start, int end, String value);

  remove(int start, int end);

  forEach(bool Function(int value, int index, LookupTextValueEditor state) handler);

  TextEditingValue finalize();
}

class DefaultTextValueEditor implements TextValueEditor {
  @override
  final TextEditingValue inputValue;
  @override
  final MutableTextRange? selection;
  @override
  final MutableTextRange? composingRegion;

  @override
  List<int> codeUnits = [];

  @override
  String get text => String.fromCharCodes(codeUnits);

  @override
  int get length => codeUnits.length;

  DefaultTextValueEditor(this.inputValue)
      : selection = MutableTextRange.fromTextSelection(inputValue.selection),
        composingRegion = MutableTextRange.fromComposingRange(inputValue.composing),
        codeUnits = [...inputValue.text.codeUnits];

  @override
  int operator [](int index) {
    return codeUnits[index];
  }

  @override
  String? at(int index) {
    if (index < length) {
      return String.fromCharCode(codeUnits[index]);
    } else {
      return null;
    }
  }

  @override
  forEach(bool Function(int value, int index, LookupTextValueEditor state) handler) {
    var state = LookupTextValueEditor(this);
    do {
      handler(codeUnits[state.index], state.index, state);
      state.index = state.index + 1;
    } while (state.index < length);
  }

  @override
  prefix(String value) {
    codeUnits.insertAll(0, value.codeUnits);
    _adjustIndex(0, 0, value.codeUnits.length, true);
  }

  @override
  suffix(String value) {
    codeUnits.insertAll(length, value.codeUnits);
    _adjustIndex(length, length, value.codeUnits.length, false);
  }

  @override
  insert(int at, String value) {
    assert(at <= length);
    codeUnits.insertAll(at, value.codeUnits);
    _adjustIndex(at, at, value.codeUnits.length);
  }

  @override
  replace(int start, int end, String value) {
    assert(start <= end);
    assert(end <= length);
    codeUnits.removeRange(start, end);
    codeUnits.insertAll(start, value.codeUnits);
    _adjustIndex(start, end, value.codeUnits.length);
  }

  @override
  remove(int start, int end) {
    assert(start <= end);
    assert(end <= length);
    codeUnits.removeRange(start, end);
    _adjustIndex(start, end, 0);
  }

  _adjustIndex(
    int regionStart,
    int regionEnd,
    int length, [
    bool moveToEnd = true,
  ]) {
    if (length != regionEnd - regionStart) {
      int adjustIndex(int originalIndex) {
        // The length added by adding the replacementString.
        final int replacedLength = (originalIndex <= regionStart &&
                ((moveToEnd && originalIndex < regionEnd) || (!moveToEnd && originalIndex <= regionEnd)))
            ? 0
            : length;
        // The length removed by removing the replacementRange.
        final int removedLength = originalIndex.clamp(regionStart, regionEnd) - regionStart;
        return replacedLength - removedLength;
      }

      if (selection != null) {
        selection?.base += adjustIndex(selection!.base);
        selection?.extent += adjustIndex(selection!.extent);
      }
      if (composingRegion != null) {
        composingRegion?.base += adjustIndex(composingRegion!.base);
        composingRegion?.extent += adjustIndex(composingRegion!.extent);
      }
    }
  }

  @override
  TextEditingValue finalize() {
    final MutableTextRange? selection = this.selection;
    final MutableTextRange? composingRegion = this.composingRegion;
    return TextEditingValue(
      text: text,
      composing: composingRegion == null || composingRegion.base == composingRegion.extent
          ? TextRange.empty
          : TextRange(start: composingRegion.base, end: composingRegion.extent),
      selection: selection == null
          ? const TextSelection.collapsed(offset: -1)
          : TextSelection(
              baseOffset: selection.base,
              extentOffset: selection.extent,
              // Try to preserve the selection affinity and isDirectional. This
              // may not make sense if the selection has changed.
              affinity: inputValue.selection.affinity,
              isDirectional: inputValue.selection.isDirectional,
            ),
    );
  }

  @override
  String toString() {
    return text;
  }
}

class LookupTextValueEditor implements TextValueEditor {
  TextValueEditor editor;
  int index;

  LookupTextValueEditor(this.editor) : index = 0;

  @override
  List<int> get codeUnits => editor.codeUnits;

  @override
  int operator [](int index) {
    return editor[index];
  }

  @override
  int get length => editor.length;

  @override
  String get text => editor.text;

  int get currentCode => editor[index];

  String get currentValue => String.fromCharCode(editor[index]);

  @override
  TextEditingValue get inputValue => editor.inputValue;

  @override
  MutableTextRange? get selection => editor.selection;

  @override
  MutableTextRange? get composingRegion => editor.composingRegion;

  @override
  String? at(int index) {
    return editor.at(index);
  }

  @override
  prefix(String value) {
    index += value.length;
    return editor.prefix(value);
  }

  @override
  suffix(String value) {
    return editor.suffix(value);
  }

  @override
  insert(int index, String value) {
    index = _fixIndex(index);
    if (index <= this.index) {
      index += value.length;
    }
    return editor.insert(index, value);
  }

  @override
  replace(int start, int end, String value) {
    start = _fixIndex(start);
    end = _fixIndex(end);
    if (start > end) {
      start = start ^ end;
      end = end ^ start;
      start = start ^ end;
    }
    if (start <= index) {
      if (end <= index) {
        index += value.length - end + start;
      } else {
        index = value.length + start;
      }
    }
    return editor.replace(start, end, value);
  }

  @override
  remove(int start, int end) {
    start = _fixIndex(start);
    end = _fixIndex(end);
    if (start > end) {
      start = start ^ end;
      end = end ^ start;
      start = start ^ end;
    }
    if (start <= index) {
      if (end <= index) {
        index += start - end;
      } else {
        index = start;
      }
    }
    return editor.remove(start, end);
  }

  _fixIndex(int index) {
    if (index < 0) {
      index = 0;
    } else if (index > length) {
      index = length;
    } else {
      return index;
    }
  }

  @override
  forEach(bool Function(int value, int index, LookupTextValueEditor state) handler) {
    throw UnimplementedError();
  }

  @override
  TextEditingValue finalize() {
    return editor.finalize();
  }
}

class MutableTextRange {
  MutableTextRange(this.base, this.extent);

  static MutableTextRange? fromComposingRange(TextRange range) {
    return range.isValid && !range.isCollapsed ? MutableTextRange(range.start, range.end) : null;
  }

  static MutableTextRange? fromTextSelection(TextSelection selection) {
    return selection.isValid ? MutableTextRange(selection.baseOffset, selection.extentOffset) : null;
  }

  /// The start index of the range, inclusive.
  ///
  /// The value of [base] should always be greater than or equal to 0, and can
  /// be larger than, smaller than, or equal to [extent].
  int base;

  /// The end index of the range, exclusive.
  ///
  /// The value of [extent] should always be greater than or equal to 0, and can
  /// be larger than, smaller than, or equal to [base].
  int extent;
}
