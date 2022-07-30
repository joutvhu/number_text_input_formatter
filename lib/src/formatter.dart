import 'package:flutter/services.dart';

import 'editor.dart';

part 'filter.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  static final numberTester = RegExp(r'^([1-9][0-9]*)(\\.[0-9]+)?$');

  final String? prefix;
  final String? suffix;
  final bool allowNegative;
  final bool insertDecimalPoint;
  final bool addDecimalDigits;
  final bool overrideDecimalPoint;

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
    this.allowNegative = false,
    this.overrideDecimalPoint = false,
    this.insertDecimalPoint = false,
    this.addDecimalDigits = false,
  })  : assert(integerDigits == null || integerDigits > 0),
        assert(decimalDigits == null || decimalDigits >= 0) {
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
        if (maxDecimal != null && maxDecimal.length > decimalDigits) {
          maxDecimal = maxDecimal.substring(0, decimalDigits);
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
    TextNumberFilter numberFilter = createFilter(state);
    numberFilter.setup(isRemoving: isRemovedCharacter).filter();

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
    String? prefix = '\$ ',
    String? suffix,
    bool allowNegative = false,
    int? integerDigits,
    int decimalDigits = 2,
  }) : super(
          prefix: prefix,
          suffix: suffix,
          allowNegative: allowNegative,
          integerDigits: integerDigits,
          decimalDigits: decimalDigits,
          addDecimalDigits: true,
        );
}

class PercentageTextInputFormatter extends NumberTextInputFormatter {
  PercentageTextInputFormatter({
    String? prefix,
    String? suffix,
    int? decimalDigits,
  }) : super(
          prefix: prefix,
          suffix: suffix,
          allowNegative: false,
          integerDigits: 3,
          decimalDigits: decimalDigits,
          maxValue: '100.00',
        );
}
