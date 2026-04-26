import 'package:flutter/services.dart';

import 'editor.dart';

part 'filter.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  static final numberTester = RegExp(r'^0*([1-9][0-9]*)(\.([0-9]+))?$');

  /// Insert prefix after format.
  final String? prefix;

  /// Insert suffix after format.
  final String? suffix;

  /// Maximum value of integer.
  late final String? maxInteger;

  /// The maximum value of the decimal when the integer part reaches the maximum.
  late final String? maxDecimal;

  /// Maximum number of integer digits.
  late final int? integerDigits;

  /// Maximum number of decimal digits.
  late final int? decimalDigits;

  /// Decimal Separator: default is dot.
  final String decimalSeparator;

  /// Allow input of negative numbers?
  final bool allowNegative;

  /// Insert 0 before the decimal point if the number starts with a decimal point
  /// Insert 0 after the decimal point if the number ends with a decimal point
  final bool fixNumber;

  /// Automatically insert decimal point.
  final bool insertDecimalPoint;

  /// Always add decimal digits.
  final bool insertDecimalDigits;

  /// Allow to change decimal point position?
  final bool overrideDecimalPoint;

  /// Grouping of 2 or more digits with groupIntegerSeparator.
  final int? groupDigits;

  /// Grouping separator: default is comma.
  final String groupSeparator;

  NumberTextInputFormatter({
    this.prefix,
    this.suffix,
    int? integerDigits,
    int? decimalDigits,
    String? maxValue,
    this.decimalSeparator = '.',
    this.groupDigits,
    this.groupSeparator = ',',
    this.allowNegative = false,
    this.overrideDecimalPoint = false,
    this.fixNumber = true,
    this.insertDecimalPoint = false,
    this.insertDecimalDigits = false,
  })  : assert(integerDigits == null || integerDigits > 0),
        assert(decimalDigits == null || decimalDigits >= 0),
        assert(decimalSeparator.length == 1),
        assert(groupDigits == null || groupDigits > 1),
        assert(groupSeparator.length == 1),
        assert(decimalSeparator != groupSeparator) {
    String? maxInteger;
    String? maxDecimal;

    if (maxValue != null) {
      var maxValues = numberTester.matchAsPrefix(maxValue);
      assert(maxValues != null && maxValues.groupCount > 0);
      maxInteger = maxValues?.group(1);
      maxDecimal = maxValues?.group(3);

      if (integerDigits != null) {
        if (maxInteger != null) {
          if (maxInteger.length <= integerDigits) {
            integerDigits = maxInteger.length;
          } else {
            maxInteger =
                maxInteger.substring(maxInteger.length - integerDigits);
          }
        }
      } else {
        integerDigits = maxInteger?.length;
      }

      if (decimalDigits != null) {
        if (maxDecimal != null) {
          if (maxDecimal.length > decimalDigits) {
            maxDecimal = maxDecimal.substring(0, decimalDigits);
          } else if (maxDecimal.length < decimalDigits) {
            maxDecimal += '0' * (decimalDigits - maxDecimal.length);
          }
        }
      } else {
        decimalDigits = maxDecimal?.length;
      }
    }

    this.maxInteger = maxInteger;
    this.maxDecimal = maxDecimal;
    // ignore: prefer_initializing_formals
    this.integerDigits = integerDigits;
    // ignore: prefer_initializing_formals
    this.decimalDigits = decimalDigits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty == true) return newValue;

    // Detect when a group separator was deleted (backspace over auto-inserted separator).
    // In that case, also remove the digit immediately before the deletion point
    // so the user perceives a real deletion rather than the separator being re-inserted.
    if (groupDigits != null &&
        newValue.text.length == oldValue.text.length - 1) {
      final cursorPos = newValue.selection.baseOffset;
      // Find which character was removed by comparing old and new text.
      int deletedIndex = -1;
      for (int i = 0; i < newValue.text.length; i++) {
        if (i >= oldValue.text.length || newValue.text[i] != oldValue.text[i]) {
          deletedIndex = i;
          break;
        }
      }
      if (deletedIndex == -1) deletedIndex = oldValue.text.length - 1;

      final deletedChar = oldValue.text[deletedIndex];
      if (deletedChar == groupSeparator) {
        // The deleted character was a group separator — also remove the digit before it.
        final removeAt = deletedIndex - 1;
        if (removeAt >= 0 && removeAt < newValue.text.length) {
          final fixedText = newValue.text.substring(0, removeAt) +
              newValue.text.substring(removeAt + 1);
          final fixedCursor = (cursorPos - 1).clamp(0, fixedText.length);
          return formatEditUpdate(
            oldValue,
            newValue.copyWith(
              text: fixedText,
              selection: TextSelection.collapsed(offset: fixedCursor),
            ),
          );
        }
      }
    }

    TextValueEditor state = TextValueEditor(newValue);
    TextNumberFilter(this, state)
      ..prepare({'removing': oldValue.text.length - 1 == newValue.text.length})
      ..filter();

    if (state.isNotEmpty) {
      if (prefix != null) {
        state.prefix(prefix!);
      }
      if (suffix != null) {
        state.suffix(suffix!);
      }
    }

    return state.finalize();
  }
}

class CurrencyTextInputFormatter extends NumberTextInputFormatter {
  CurrencyTextInputFormatter({
    String? prefix,
    String? suffix,
    int? integerDigits,
    int decimalDigits = 2,
    String? maxValue,
    bool allowNegative = false,
    String decimalSeparator = '.',
    int groupDigits = 3,
    String groupSeparator = ',',
    bool overrideDecimalPoint = false,
    bool insertDecimalPoint = true,
    bool insertDecimalDigits = false,
  }) : super(
          prefix: prefix,
          suffix: suffix,
          integerDigits: integerDigits,
          decimalDigits: decimalDigits,
          maxValue: maxValue,
          allowNegative: allowNegative,
          decimalSeparator: decimalSeparator,
          groupDigits: groupDigits,
          groupSeparator: groupSeparator,
          overrideDecimalPoint: overrideDecimalPoint,
          insertDecimalPoint: insertDecimalPoint,
          insertDecimalDigits: insertDecimalDigits,
        );
}

class PercentageTextInputFormatter extends NumberTextInputFormatter {
  PercentageTextInputFormatter({
    String? prefix,
    String? suffix,
    int integerDigits = 3,
    int decimalDigits = 0,
    bool allowNegative = false,
    String decimalSeparator = '.',
    int? groupDigits,
    String groupSeparator = ',',
    bool overrideDecimalPoint = false,
    bool insertDecimalPoint = false,
    bool insertDecimalDigits = true,
  })  : assert(integerDigits >= 3),
        super(
          prefix: prefix,
          suffix: suffix,
          integerDigits: integerDigits,
          decimalDigits: decimalDigits,
          maxValue:
              '1${'0' * (integerDigits - 1)}${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}',
          allowNegative: allowNegative,
          decimalSeparator: decimalSeparator,
          groupDigits: groupDigits,
          groupSeparator: groupSeparator,
          overrideDecimalPoint: overrideDecimalPoint,
          insertDecimalPoint: insertDecimalPoint,
          insertDecimalDigits: insertDecimalDigits,
        );
}
