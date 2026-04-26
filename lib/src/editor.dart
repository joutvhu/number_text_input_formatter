import 'package:flutter/services.dart';

/// Callback invoked for each character during a [TextValueEditor.forEach] traversal.
///
/// [value] is the UTF-16 code unit of the current character, [index] is its
/// position in the editor, and [state] is the mutable editor state at that
/// position. Return `false` to stop iteration early.
typedef NextHandler = bool Function(
    int value, int index, LookupTextValueEditor state);

/// Callback invoked after a [TextValueEditor.forEach] traversal completes.
///
/// [length] is the final length of the editor content and [state] is the
/// mutable editor state at the end of iteration.
typedef CompleteHandler = void Function(
    int length, LookupTextValueEditor state);

/// An interface for reading and mutating the text content of a [TextEditingValue].
///
/// Provides character-level access and mutation operations (insert, replace,
/// remove, prefix, suffix) while automatically adjusting the cursor selection
/// and composing region to stay consistent with the changes.
///
/// Use the factory constructor to obtain a [DefaultTextValueEditor]:
/// ```dart
/// final editor = TextValueEditor(textEditingValue);
/// ```
abstract class TextValueEditor {
  /// Creates a [TextValueEditor] backed by [inputValue].
  factory TextValueEditor(TextEditingValue inputValue) =>
      DefaultTextValueEditor(inputValue);

  /// The UTF-16 code units of the current text content.
  List<int> get codeUnits;

  /// Returns the UTF-16 code unit at [index].
  int operator [](int index);

  /// The number of characters in the current text.
  int get length;

  /// The current text content as a [String].
  String get text;

  /// Whether the text content is empty.
  bool get isEmpty;

  /// Whether the text content is non-empty.
  bool get isNotEmpty;

  /// The original [TextEditingValue] this editor was created from.
  TextEditingValue get inputValue;

  /// The mutable selection range, or `null` if the original selection was invalid.
  MutableTextRange? get selection;

  /// The mutable composing region, or `null` if there is no active composing region.
  MutableTextRange? get composingRegion;

  /// Returns the character at [index] as a [String], or `null` if [index] is out of bounds.
  String? at(int index);

  /// Inserts [value] at the beginning of the text.
  void prefix(String value);

  /// Appends [value] at the end of the text.
  void suffix(String value);

  /// Inserts [value] at [index].
  void insert(int index, String value);

  /// Replaces the range [[start], [end]) with [value].
  void replace(int start, int end, String value);

  /// Removes the range [[start], [end]).
  void remove(int start, int end);

  /// Iterates over each character, calling [next] for each code unit.
  ///
  /// Iteration stops early if [next] returns `false`. [complete] is called
  /// once after iteration finishes.
  void forEach(NextHandler next, [CompleteHandler? complete]);

  /// Produces a new [TextEditingValue] reflecting all mutations applied to this editor.
  TextEditingValue finalize();
}

/// Default implementation of [TextValueEditor].
///
/// Maintains a mutable list of UTF-16 code units and adjusts the [selection]
/// and [composingRegion] automatically whenever the text is modified.
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

  @override
  bool get isEmpty => codeUnits.isEmpty;

  @override
  bool get isNotEmpty => codeUnits.isNotEmpty;

  DefaultTextValueEditor(this.inputValue)
      : selection = MutableTextRange.fromTextSelection(inputValue.selection),
        composingRegion =
            MutableTextRange.fromComposingRange(inputValue.composing),
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
  void forEach(NextHandler next, [CompleteHandler? complete]) {
    var state = LookupTextValueEditor._(this);
    do {
      if (!next(codeUnits[state.index], state.index, state)) {
        break;
      }
      state.index = state.index + 1;
    } while (state.index < length);
    if (complete != null) {
      complete(length, state);
    }
  }

  @override
  void prefix(String value) {
    codeUnits.insertAll(0, value.codeUnits);
    _adjustIndex(0, 0, value.codeUnits.length, true);
  }

  @override
  void suffix(String value) {
    codeUnits.insertAll(length, value.codeUnits);
    _adjustIndex(length, length, value.codeUnits.length, false);
  }

  @override
  void insert(int index, String value) {
    assert(index <= length);
    codeUnits.insertAll(index, value.codeUnits);
    _adjustIndex(index, index, value.codeUnits.length);
  }

  @override
  void replace(int start, int end, String value) {
    assert(start <= end);
    assert(end <= length);
    codeUnits.removeRange(start, end);
    codeUnits.insertAll(start, value.codeUnits);
    _adjustIndex(start, end, value.codeUnits.length);
  }

  @override
  void remove(int start, int end) {
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
                ((moveToEnd && originalIndex < regionEnd) ||
                    (!moveToEnd && originalIndex <= regionEnd)))
            ? 0
            : length;
        // The length removed by removing the replacementRange.
        final int removedLength =
            originalIndex.clamp(regionStart, regionEnd) - regionStart;
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
      composing: composingRegion == null ||
              composingRegion.base == composingRegion.extent
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

/// A [TextValueEditor] wrapper that tracks a current iteration [index].
///
/// Used internally during [TextValueEditor.forEach] traversal to allow
/// filter callbacks to insert, replace, or remove characters relative to
/// the current position while keeping [index] consistent.
class LookupTextValueEditor implements TextValueEditor {
  /// The underlying editor being wrapped.
  TextValueEditor editor;

  /// The current character index during iteration.
  int index;

  LookupTextValueEditor._(this.editor) : index = 0;

  @override
  List<int> get codeUnits => editor.codeUnits;

  @override
  int operator [](int index) {
    return editor[index];
  }

  @override
  String get text => editor.text;

  @override
  int get length => editor.length;

  @override
  bool get isEmpty => editor.isEmpty;

  @override
  bool get isNotEmpty => editor.isNotEmpty;

  /// The UTF-16 code unit of the character at the current [index].
  int get currentCode => editor[index];

  /// The character at the current [index] as a [String].
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
  void prefix(String value) {
    index += value.length;
    editor.prefix(value);
  }

  @override
  void suffix(String value) {
    if (index == length) {
      index += value.length;
    }
    editor.suffix(value);
  }

  @override
  void insert(int index, String value) {
    index = _fixIndex(index);
    if (index <= this.index) {
      this.index += value.length;
    }
    editor.insert(index, value);
  }

  /// Inserts [value] immediately before the current [index], advancing [index] past it.
  void insertBefore(String value) {
    index += value.length;
    editor.insert(index, value);
  }

  /// Inserts [value] immediately after the current [index].
  void insertAfter(String value) {
    editor.insert(index, value);
  }

  @override
  void replace(int start, int end, String value) {
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
    editor.replace(start, end, value);
  }

  @override
  void remove(int start, int end) {
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
    editor.remove(start, end);
  }

  int _fixIndex(int index) {
    if (index < 0) {
      return 0;
    } else if (index > length) {
      return length;
    } else {
      return index;
    }
  }

  @override
  void forEach(NextHandler next, [CompleteHandler? complete]) {
    var state = LookupTextValueEditor._(this);
    do {
      if (!next(codeUnits[state.index], state.index, state)) {
        break;
      }
      state.index = state.index + 1;
    } while (state.index < length);
    if (complete != null) {
      complete(length, state);
    }
  }

  @override
  TextEditingValue finalize() {
    return editor.finalize();
  }
}

/// A mutable text range with independently adjustable [base] and [extent] offsets.
///
/// Used internally to track and update the cursor selection and composing
/// region as text mutations are applied.
class MutableTextRange {
  /// Creates a range with the given [base] and [extent] offsets.
  MutableTextRange(this.base, this.extent);

  /// Creates a [MutableTextRange] from a [TextRange] if it is valid and non-collapsed,
  /// otherwise returns `null`.
  static MutableTextRange? fromComposingRange(TextRange range) {
    return range.isValid && !range.isCollapsed
        ? MutableTextRange(range.start, range.end)
        : null;
  }

  /// Creates a [MutableTextRange] from a [TextSelection] if it is valid,
  /// otherwise returns `null`.
  static MutableTextRange? fromTextSelection(TextSelection selection) {
    return selection.isValid
        ? MutableTextRange(selection.baseOffset, selection.extentOffset)
        : null;
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
