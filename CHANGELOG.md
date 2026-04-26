## 1.0.0+9

- Fix backspace over group separator: deleting a group separator now also removes the preceding digit, preventing the cursor from getting stuck.
- Fix `_fixIndex` not returning clamped value in `LookupTextValueEditor`.
- Remove unused constants (`_comma`, `_dot`, `_number_1` through `_number_8`) in filter.
- Add return types to all methods in `TextValueEditor`, `DefaultTextValueEditor`, and `LookupTextValueEditor`.
- Fix `PercentageTextInputFormatter` assert to use `>= 3` instead of `> 2`.
- Update README with full parameter documentation and fix syntax error in example.
- Add 21 new test cases covering prefix/suffix, groupDigits, decimalDigits: 0, maxValue, allowNegative: false, CurrencyTextInputFormatter, and PercentageTextInputFormatter.

## 1.0.0+8

- Fix insert integer digit

## 1.0.0+7

- Bump SDK version

## 1.0.0+6

- Fix insertDecimalPoint with negative number.

## 1.0.0+5

- Fix group of negative number.

## 1.0.0+4

- Allow disable fix number.

## 1.0.0+3

- Fix maxDecimal issue.

## 1.0.0+2

- Fix maxValue issue.

## 1.0.0+1

- Check isNotEmpty before insert prefix or suffix.

## 1.0.0

- Initial library
- Support NumberTextInputFormatter, CurrencyTextInputFormatter and PercentageTextInputFormatter.
