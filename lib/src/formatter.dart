import 'package:flutter/services.dart';

import 'editor.dart';

part 'filter.dart';

class NumberTextInputFormatter extends TextInputFormatter {
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
    this.allowNegative = false,
    int? integerDigits,
    int? decimalDigits,
    String? maxValue,
    this.overrideDecimalPoint = false,
    this.insertDecimalPoint = false,
    this.addDecimalDigits = false,
  })  : assert(integerDigits == null || integerDigits > 0),
        assert(decimalDigits == null || decimalDigits >= 0) {
    if (maxValue != null) {
      var maxValues = maxValue.split('.');
      maxInteger = maxValues[0];
      maxDecimal = maxValues[1];

      if (maxInteger != null) {
        this.integerDigits =
            integerDigits == null || maxInteger!.length < integerDigits ? maxInteger!.length : integerDigits;
      } else {
        this.integerDigits = integerDigits;
      }

      if (maxDecimal != null) {
        this.decimalDigits =
            decimalDigits == null || maxDecimal!.length < decimalDigits ? maxDecimal!.length : decimalDigits;
      } else {
        this.decimalDigits = decimalDigits;
      }
    } else {
      this.integerDigits = integerDigits;
      this.decimalDigits = decimalDigits;
    }
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
          integerDigits: 2,
          decimalDigits: decimalDigits,
          maxValue: '100.00',
        );

  @override
  TextNumberFilter createFilter(TextValueEditor state) {
    return TextPercentageFilter(this, state);
  }
}
