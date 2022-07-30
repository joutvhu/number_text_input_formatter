import 'package:flutter/widgets.dart';

class TextValueEditor {
  final TextEditingValue inputValue;
  final MutableTextRange? selection;
  final MutableTextRange? composingRegion;

  List<int> codeUnits = [];

  String get text => String.fromCharCodes(codeUnits);

  int get length => codeUnits.length;

  TextValueEditor(this.inputValue)
      : selection = MutableTextRange.fromTextSelection(inputValue.selection),
        composingRegion = MutableTextRange.fromComposingRange(inputValue.composing),
        codeUnits = [...inputValue.text.codeUnits];

  int operator [](int index) {
    return codeUnits[index];
  }

  String? at(int index) {
    if (index < length) {
      return String.fromCharCode(codeUnits[index]);
    } else {
      return null;
    }
  }

  prefix(String value) {
    codeUnits.insertAll(0, value.codeUnits);
    _adjustIndex(0, 0, value.codeUnits.length, true);
  }

  suffix(String value) {
    codeUnits.insertAll(length, value.codeUnits);
    _adjustIndex(length, length, value.codeUnits.length, false);
  }

  insert(int at, String value) {
    assert(at <= length);
    codeUnits.insertAll(at, value.codeUnits);
    _adjustIndex(at, at, value.codeUnits.length);
  }

  replace(int start, int end, String value) {
    assert(start <= end);
    assert(end <= length);
    codeUnits.removeRange(start, end);
    codeUnits.insertAll(start, value.codeUnits);
    _adjustIndex(start, end, value.codeUnits.length);
  }

  remove(int start, int end) {
    assert(start <= end);
    assert(end <= length);
    codeUnits.removeRange(start, end);
    _adjustIndex(start, end, 0);
  }

  void _adjustIndex(
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
