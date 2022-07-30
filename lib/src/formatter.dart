import 'package:flutter/services.dart';

import 'editor.dart';

part 'filter.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  static final numberTester = RegExp(r'^0*([1-9][0-9]*)(\.([0-9]+))?$');

  final String? prefix;
  final String? suffix;

  /// Allow input of negative numbers?
  final bool allowNegative;
  /// Automatically insert decimal point.
  final bool insertDecimalPoint;
  /// Always add decimals.
  final bool addDecimalDigits;
  /// Allow to change decimal point position?
  final bool overrideDecimalPoint;

  late final int? groupIntegerDigits;

  late final String? maxInteger;
  late final String? maxDecimal;
  late final int? integerDigits;
  late final int? decimalDigits;

  NumberTextInputFormatter({
    this.prefix,
    this.suffix,
    int? integerDigits,
    int? decimalDigits,
    String? maxValue,
    this.groupIntegerDigits,
    this.allowNegative = false,
    this.overrideDecimalPoint = false,
    this.insertDecimalPoint = false,
    this.addDecimalDigits = false,
  })  : assert(integerDigits == null || integerDigits > 0),
        assert(decimalDigits == null || decimalDigits >= 0),
        assert(groupIntegerDigits == null || groupIntegerDigits > 1) {
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
            maxInteger = maxInteger.substring(maxInteger.length - integerDigits);
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
    this.integerDigits = integerDigits;
    this.decimalDigits = decimalDigits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty == true) return newValue;

    final bool isRemovedCharacter = oldValue.text.length - 1 == newValue.text.length;
    TextValueEditor state = TextValueEditor(newValue);
    createFilter(state).setup(isRemoving: isRemovedCharacter).filter();

    if (state.toString().isNotEmpty) {
      if (prefix != null) {
        state.prefix(prefix!);
      }
      if (suffix != null) {
        state.suffix(suffix!);
      }
    }

    return state.finalize();
  }

  TextNumberFilter createFilter(TextValueEditor state) {
    return TextNumberFilter(this, state);
  }
}

class DollarTextInputFormatter extends NumberTextInputFormatter {
  DollarTextInputFormatter({
    String? prefix,
    String? suffix,
    int? integerDigits,
    int decimalDigits = 2,
    String? maxValue,
    bool allowNegative = false,
    int groupIntegerDigits = 3,
    bool overrideDecimalPoint = false,
    bool insertDecimalPoint = true,
    bool addDecimalDigits = false,
  }) : super(
          prefix: prefix,
          suffix: suffix,
          integerDigits: integerDigits,
          decimalDigits: decimalDigits,
          maxValue: maxValue,
          allowNegative: allowNegative,
          groupIntegerDigits : groupIntegerDigits,
          overrideDecimalPoint: overrideDecimalPoint,
          insertDecimalPoint: insertDecimalPoint,
          addDecimalDigits: addDecimalDigits,
        );
}

class PercentageTextInputFormatter extends NumberTextInputFormatter {
  PercentageTextInputFormatter({
    String? prefix,
    String? suffix,
    int integerDigits = 3,
    int decimalDigits = 0,
    bool allowNegative = false,
    int? groupIntegerDigits,
    bool overrideDecimalPoint = false,
    bool insertDecimalPoint = false,
    bool addDecimalDigits = true,
  })  : assert(integerDigits > 2),
        super(
          prefix: prefix,
          suffix: suffix,
          integerDigits: integerDigits,
          decimalDigits: decimalDigits,
          maxValue: '1${'0' * (integerDigits - 1)}${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}',
          allowNegative: allowNegative,
          groupIntegerDigits: groupIntegerDigits,
          overrideDecimalPoint: overrideDecimalPoint,
          insertDecimalPoint: insertDecimalPoint,
          addDecimalDigits: addDecimalDigits,
        );
}
