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
    var result = NumberTextInputFormatter(integerDigits: 2, decimalDigits: 2, maxValue: '1.33').formatEditUpdate(
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
    var result = NumberTextInputFormatter(integerDigits: 12, groupDigits: 3, fixNumber: false).formatEditUpdate(
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
    var result = NumberTextInputFormatter(integerDigits: 12, groupDigits: 3, fixNumber: false).formatEditUpdate(
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
    var result = CurrencyTextInputFormatter(prefix: '\$').formatEditUpdate(
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

  // prefix / suffix
  test('prefix_suffix_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      prefix: '\$ ',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '1234'),
    );
    expect(result.text, '\$ 1234');
  });

  test('prefix_suffix_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      suffix: ' USD',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '1234'),
    );
    expect(result.text, '1234 USD');
  });

  test('prefix_suffix_3', () {
    // prefix and suffix should not be added when result is empty
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      prefix: '\$ ',
      suffix: ' USD',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: 'abc'),
    );
    expect(result.text, '');
  });

  // empty input
  test('empty_input_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(text: '5'),
      const TextEditingValue(text: ''),
    );
    expect(result.text, '');
  });

  // group digits
  test('group_digits_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 3,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '1234567'),
    );
    expect(result.text, '1,234,567');
  });

  test('group_digits_2', () {
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 3,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '123'),
    );
    expect(result.text, '123');
  });

  test('group_digits_3', () {
    // group of 2
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '123456'),
    );
    expect(result.text, '12,34,56');
  });

  // fix_number
  test('fix_number_leading_decimal_1', () {
    // fixNumber: true should prepend 0 before leading dot
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '.5'),
    );
    expect(result.text, '0.5');
  });

  test('fix_number_trailing_decimal_1', () {
    // fixNumber: true should keep trailing dot as-is (no decimal digits appended unless insertDecimalDigits)
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      fixNumber: true,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '5.'),
    );
    expect(result.text, '5.00');
  });

  // decimalDigits: 0 (integer only)
  test('decimal_digits_zero_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 0,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '123.45'),
    );
    expect(result.text, '12345');
  });

  test('decimal_digits_zero_2', () {
    // decimal separator should be rejected when decimalDigits is 0
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 0,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '99.'),
    );
    expect(result.text, '99');
  });

  // maxValue only (no explicit integerDigits / decimalDigits)
  test('max_value_only_1', () {
    var result = NumberTextInputFormatter(
      maxValue: '999.99',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '1000'),
    );
    expect(result.text, '100');
  });

  test('max_value_only_2', () {
    var result = NumberTextInputFormatter(
      maxValue: '999.99',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '500.12'),
    );
    expect(result.text, '500.12');
  });

  // allow_negative: false (default) — negative sign should be stripped
  test('disallow_negative_1', () {
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '-123.45'),
    );
    expect(result.text, '123.45');
  });

  // CurrencyTextInputFormatter
  test('currency_text_input_formatter_2', () {
    // no input → empty
    var result = CurrencyTextInputFormatter().formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: ''),
    );
    expect(result.text, '');
  });

  test('currency_text_input_formatter_3', () {
    // suffix variant
    var result = CurrencyTextInputFormatter(
      suffix: ' VND',
      groupDigits: 3,
      groupSeparator: '.',
      decimalSeparator: ',',
      decimalDigits: 0,
      insertDecimalPoint: false,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '1500000'),
    );
    expect(result.text, '1.500.000 VND');
  });

  test('currency_text_input_formatter_4', () {
    // negative currency
    var result = CurrencyTextInputFormatter(
      allowNegative: true,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '-5000'),
    );
    expect(result.text, '-50.00');
  });

  // PercentageTextInputFormatter
  test('percentage_text_input_formatter_5', () {
    // value at exact max (100) should be allowed
    var result = PercentageTextInputFormatter().formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '100'),
    );
    expect(result.text, '100');
  });

  test('percentage_text_input_formatter_6', () {
    // value above max (101) should be clamped
    var result = PercentageTextInputFormatter().formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '101'),
    );
    expect(result.text, '10');
  });

  test('percentage_text_input_formatter_7', () {
    // single digit
    var result = PercentageTextInputFormatter(
      suffix: '%',
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '5'),
    );
    expect(result.text, '5%');
  });

  // backspace over group separator
  test('backspace_over_group_separator_1', () {
    // "12,345" cursor after comma → backspace deletes comma → should also remove "2" → "1,345"
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 3,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '12,345',
        selection: TextSelection.collapsed(offset: 3),
      ),
      const TextEditingValue(
        text: '12345',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    expect(result.text, '1,345');
  });

  test('backspace_over_group_separator_2', () {
    // "1,234,567" cursor after first comma → backspace → "234,567"
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 3,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '1,234,567',
        selection: TextSelection.collapsed(offset: 2),
      ),
      const TextEditingValue(
        text: '1234,567',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    expect(result.text, '234,567');
  });

  test('backspace_over_group_separator_3', () {
    // Deleting a real digit (not separator) should work normally
    var result = NumberTextInputFormatter(
      integerDigits: 13,
      groupDigits: 3,
    ).formatEditUpdate(
      const TextEditingValue(
        text: '12,345',
        selection: TextSelection.collapsed(offset: 6),
      ),
      const TextEditingValue(
        text: '12,34',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    expect(result.text, '1,234');
  });

  test('backspace_over_group_separator_4', () {
    // Currency: "1,791,251.41" cursor after first comma → backspace → "179,125.14" (insertDecimalPoint)
    var result = CurrencyTextInputFormatter().formatEditUpdate(
      const TextEditingValue(
        text: '1,791,251.41',
        selection: TextSelection.collapsed(offset: 2),
      ),
      const TextEditingValue(
        text: '1791,251.41',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    expect(result.text, '791,251.41');
  });

  // fixNumber: false — input zero into empty field
  test('fix_number_false_zero_1', () {
    // typing "0" into empty field should produce "0"
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      fixNumber: false,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '0'),
    );
    expect(result.text, '0');
  });

  test('fix_number_false_zero_2', () {
    // leading zeros should still be stripped: "007" → "7"
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      fixNumber: false,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '007'),
    );
    expect(result.text, '7');
  });

  test('fix_number_false_zero_3', () {
    // "0" followed by another digit should strip the leading zero: "05" → "5"
    var result = NumberTextInputFormatter(
      integerDigits: 10,
      fixNumber: false,
    ).formatEditUpdate(
      const TextEditingValue(text: '0'),
      const TextEditingValue(text: '05'),
    );
    expect(result.text, '5');
  });

  test('fix_number_false_zero_4', () {
    // fixNumber: true (default) should still work normally
    var result = NumberTextInputFormatter(
      integerDigits: 10,
    ).formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '0'),
    );
    expect(result.text, '0');
  });
}
