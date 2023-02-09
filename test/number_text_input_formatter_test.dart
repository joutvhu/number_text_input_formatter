import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

void main() {
  test('insert_non_numeric_characters_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '14.05',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '1ab%d4.05',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    expect(result.text, '14.05');
  });

  test('multiple_decimal_separators_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '14.05',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '52.5.7',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    expect(result.text, '52.57');
  });

  test('overflow_decimal_part_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.00',
        selection: TextSelection.collapsed(offset: 3),
      ),
      const TextEditingValue(
        text: '1.050',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(result.text, '1.00');
  });

  test('overflow_decimal_part_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.00',
        selection: TextSelection.collapsed(offset: 3),
      ),
      const TextEditingValue(
        text: '1.050',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    expect(result.text, '1.00');
  });

  test('integer_part_greater_than_maxValue_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      ),
      const TextEditingValue(
        text: '6',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    expect(result.text, '0');
  });

  test('integer_part_greater_than_maxValue_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '06',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '0');
  });

  test('integer_part_greater_than_maxValue_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '10.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '016',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '1');
  });

  test('integer_part_greater_than_maxValue_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '100.00',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '10',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '106',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '1');
  });

  test('integer_part_greater_than_maxValue_5', () {
    var result = NumberTextInputFormatter(
      integerDigits: 3,
      decimalDigits: 2,
      maxValue: '100.00',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '10',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '106',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '10');
  });

  test('integer_part_greater_than_maxValue_6', () {
    var result = NumberTextInputFormatter(
      maxValue: '100.09',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '10.09',
        selection: TextSelection.collapsed(offset: 1),
      ),
      const TextEditingValue(
        text: '106.12',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '10.12');
  });

  test('decimal_part_greater_than_maxValue_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.33',
        selection: TextSelection.collapsed(offset: 4),
      ),
      const TextEditingValue(
        text: '1.34',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(result.text, '1.3');
  });

  test('decimal_part_greater_than_maxValue_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '1.418',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.40',
        selection: TextSelection.collapsed(offset: 4),
      ),
      const TextEditingValue(
        text: '1.42',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(result.text, '1.4');
  });

  test('decimal_part_greater_than_maxValue_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '1.418',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.40',
        selection: TextSelection.collapsed(offset: 4),
      ),
      const TextEditingValue(
        text: '1.418',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(result.text, '1.41');
  });

  test('decimal_part_greater_than_maxValue_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 3,
      maxValue: '1.4',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1.40',
        selection: TextSelection.collapsed(offset: 4),
      ),
      const TextEditingValue(
        text: '1.418',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    expect(result.text, '1.4');
  });

  test('change_decimal_separator_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      decimalSeparator: ',',
      groupDigits: 3,
      groupSeparator: '.',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '2454341,418',
      ),
    );
    expect(result.text, '2.454.341,41');
  });

  test('allow_negative_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-2454.418',
      ),
    );
    expect(result.text, '-2454.41');
  });

  test('allow_negative_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '--2454.418',
      ),
    );
    expect(result.text, '-2454.41');
  });

  test('allow_negative_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-245-4.418',
      ),
    );
    expect(result.text, '-2454.41');
  });

  test('insert_decimal_point_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458',
      ),
    );
    expect(result.text, '804.58');
  });

  test('insert_decimal_point_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.',
      ),
    );
    expect(result.text, '804.58');
  });

  test('insert_decimal_point_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.1',
      ),
    );
    expect(result.text, '8045.81');
  });

  test('insert_decimal_point_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.14',
      ),
    );
    expect(result.text, '80458.14');
  });

  test('insert_decimal_point_5', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.149',
      ),
    );
    expect(result.text, '804581.49');
  });

  test('insert_decimal_point_6', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '9',
      ),
    );
    expect(result.text, '0.09');
  });

  test('insert_decimal_point_7', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '79',
      ),
    );
    expect(result.text, '0.79');
  });

  test('insert_decimal_digits_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458',
      ),
    );
    expect(result.text, '80458.00');
  });

  test('insert_decimal_digits_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.',
      ),
    );
    expect(result.text, '80458.00');
  });

  test('insert_decimal_digits_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.1',
      ),
    );
    expect(result.text, '80458.1');
  });

  test('override_decimal_point_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.366',
      ),
    );
    expect(result.text, '804583.66');
  });

  test('override_decimal_point_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.36',
      ),
    );
    expect(result.text, '80458.36');
  });

  test('override_decimal_point_3', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalPoint: true,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.3',
      ),
    );
    expect(result.text, '8045.83');
  });

  test('override_decimal_point_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.3.66',
      ),
    );
    expect(result.text, '804583.66');
  });

  test('currency_text_input_formatter_1', () {
    var result = CurrencyTextInputFormatter(
      prefix: '\$'
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '179125141',
      ),
    );
    expect(result.text, '\$1,791,251.41');
  });

  test('percentage_text_input_formatter_1', () {
    var result = PercentageTextInputFormatter(
      suffix: '%',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '144',
      ),
    );
    expect(result.text, '14%');
  });
}
