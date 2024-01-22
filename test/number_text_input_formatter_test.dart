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

  test('overflow_integer_part_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '11.050',
      ),
    );
    expect(result.text, '1.05');
  });

  test('missing_integer_part_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '.050',
      ),
    );
    expect(result.text, '0.05');
  });

  test('missing_integer_part_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: 'vfd.050',
      ),
    );
    expect(result.text, '0.05');
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
    expect(result.text, '1.05');
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
    expect(result.text, '1.05');
  });

  test('integer_part_greater_than_max_value_1', () {
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

  test('integer_part_greater_than_max_value_2', () {
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

  test('integer_part_greater_than_max_value_3', () {
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

  test('integer_part_greater_than_max_value_4', () {
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

  test('integer_part_greater_than_max_value_5', () {
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

  test('integer_part_greater_than_max_value_6', () {
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

  test('decimal_part_greater_than_max_value_1', () {
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

  test('decimal_part_greater_than_max_value_2', () {
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

  test('decimal_part_greater_than_max_value_3', () {
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

  test('decimal_part_greater_than_max_value_4', () {
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

  test('decimal_part_greater_than_max_value_5', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      maxValue: '1.33'
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '1.41',
      ),
    );
    expect(result.text, '1.00');
  });

  test('decimal_part_less_than_max_value_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '1.09',
      ),
    );
    expect(result.text, '1.09');
  });

  test('decimal_part_less_than_max_value_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 1,
      decimalDigits: 2,
      maxValue: '1.33',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '1.19',
      ),
    );
    expect(result.text, '1.19');
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

  test('allow_negative_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      groupDigits: 3,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-245.41',
      ),
    );
    expect(result.text, '-245.41');
  });

  test('allow_negative_5', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      groupDigits: 3,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-2405.41',
      ),
    );
    expect(result.text, '-2,405.41');
  });

  test('allow_negative_6', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '--245.41',
      ),
    );
    expect(result.text, '-245.41');
  });

  test('allow_negative_7', () {
    var result = CurrencyTextInputFormatter(
      allowNegative: true,
      prefix: '€ ',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-345.24',
      ),
    );
    expect(result.text, '€ -345.24');
  });

  test('allow_negative_8', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-4',
      ),
    );
    expect(result.text, '-0.04');
  });

  test('allow_negative_9', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-0',
      ),
    );
    expect(result.text, '-0.00');
  });

  test('allow_negative_10', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '-01',
      ),
      const TextEditingValue(
        text: '-0',
      ),
    );
    expect(result.text, '-');
  });

  test('allow_negative_11', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '-0',
      ),
      const TextEditingValue(
        text: '-',
      ),
    );
    expect(result.text, '-');
  });

  test('allow_negative_12', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-10.',
      ),
    );
    expect(result.text, '-10.00');
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

  test('insert_decimal_digits_4', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '80458.yuty',
      ),
    );
    expect(result.text, '80458.00');
  });

  test('insert_decimal_digits_5', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      insertDecimalDigits: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '8045ujy8',
      ),
    );
    expect(result.text, '80458.00');
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

  test('override_decimal_point_5', () {
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
        text: '80458.htrt',
      ),
    );
    expect(result.text, '80458.00');
  });

  test('override_decimal_point_6', () {
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
        text: '8045tg8',
      ),
    );
    expect(result.text, '80458.00');
  });

  test('override_decimal_point_7', () {
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
        text: '804y5.g8.u5',
      ),
    );
    expect(result.text, '80458.5');
  });

  test('override_decimal_point_8', () {
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
        text: '8045t.g8.u568',
      ),
    );
    expect(result.text, '80458.56');
  });

  test('override_decimal_point_9', () {
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
        text: '80458.3.606',
      ),
    );
    expect(result.text, '804583.60');
  });

  test('override_decimal_point_10', () {
    var result = NumberTextInputFormatter(
      integerDigits: 2,
      decimalDigits: 2,
      insertDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '58',
      ),
    );
    expect(result.text, '0.58');
  });

  test('filter_other_decimal_point_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '1.3a.66',
      ),
    );
    expect(result.text, '13.66');
  });

  test('filter_other_decimal_point_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      decimalDigits: 2,
      overrideDecimalPoint: true,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '0.3.66',
      ),
    );
    expect(result.text, '3.66');
  });

  test('filter_fix_number_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 12,
      groupDigits: 3,
      fixNumber: false
    ).formatEditUpdate(
      const TextEditingValue(
        text: '11',
      ),
      const TextEditingValue(
        text: '11.',
      ),
    );
    expect(result.text, '11.');
  });

  test('filter_fix_number_2', () {
    var result = NumberTextInputFormatter(
        integerDigits: 12,
        groupDigits: 3,
        fixNumber: false
    ).formatEditUpdate(
      const TextEditingValue(
        text: '11',
      ),
      const TextEditingValue(
        text: '.11',
      ),
    );
    expect(result.text, '.11');
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

  test('percentage_text_input_formatter_2', () {
    var result = PercentageTextInputFormatter(
      integerDigits: 12,
      decimalDigits: 2,
      decimalSeparator: '.',
      groupDigits: 3,
      groupSeparator: ',',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '.',
      ),
    );
    expect(result.text, '0.00');
  });

  test('percentage_text_input_formatter_3', () {
    var result = PercentageTextInputFormatter(
      integerDigits: 12,
      decimalDigits: 2,
      decimalSeparator: '.',
      groupDigits: 3,
      groupSeparator: ',',
      allowNegative: true,
      overrideDecimalPoint: false,
      insertDecimalPoint: false,
      insertDecimalDigits: false,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '-.',
      ),
    );
    expect(result.text, '-0.00');
  });

  test('percentage_text_input_formatter_4', () {
    var result = PercentageTextInputFormatter(
      integerDigits: 12,
      decimalDigits: 2,
      decimalSeparator: '.',
      groupDigits: 3,
      groupSeparator: ',',
    ).formatEditUpdate(
      const TextEditingValue(
        text: '',
      ),
      const TextEditingValue(
        text: '.24',
      ),
    );
    expect(result.text, '0.24');
  });
}
