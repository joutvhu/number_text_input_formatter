# Number Text Input Formatter

Number Text Input Formatter for Flutter.

## Installation

```yaml
# Add into pubspec.yaml
dependencies:
  number_text_input_formatter: ^1.0.0+1
```

## Usage

For number

```dart
TextField(
  inputFormatters: [
    NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      maxValue: '1000000000.00',
      decimalSeparator: '.',
      groupDigits: 3,
      groupSeparator: ','
      allowNegative: false,
      overrideDecimalPoint: true,
      insertDecimalPoint: false,
      insertDecimalDigits: true,
    ),
  ],
  keyboardType: TextInputType.number,
),
```

For currency

```dart
TextField(
  inputFormatters: [CurrencyTextInputFormatter()],
  keyboardType: TextInputType.number,
),
```

For percentage

```dart
TextField(
  inputFormatters: [PercentageTextInputFormatter()],
  keyboardType: TextInputType.number,
),
```

