# Number Text Input Formatter

Number Text Input Formatter for Flutter.

## Installation

```yaml
dependencies:
  number_text_input_formatter: ^1.0.0
```

## Usage

### NumberTextInputFormatter

General-purpose formatter for numeric input fields.

```dart
TextField(
  inputFormatters: [
    NumberTextInputFormatter(
      integerDigits: 10,
      decimalDigits: 2,
      maxValue: '1000000000.00',
      decimalSeparator: '.',
      groupDigits: 3,
      groupSeparator: ',',
      allowNegative: false,
      overrideDecimalPoint: true,
      insertDecimalPoint: false,
      insertDecimalDigits: true,
    ),
  ],
  keyboardType: TextInputType.number,
),
```

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `integerDigits` | `int?` | `null` | Maximum number of integer digits. Must be > 0 if provided. |
| `decimalDigits` | `int?` | `null` | Maximum number of decimal digits. Must be >= 0 if provided. |
| `maxValue` | `String?` | `null` | Maximum allowed value (e.g. `'9999.99'`). Infers `integerDigits` and `decimalDigits` if not set. |
| `decimalSeparator` | `String` | `'.'` | Character used as the decimal point. Must be a single character. |
| `groupDigits` | `int?` | `null` | Group integer digits every N digits (e.g. `3` for thousands). Must be > 1 if provided. |
| `groupSeparator` | `String` | `','` | Character used as the grouping separator. Must be a single character, different from `decimalSeparator`. |
| `allowNegative` | `bool` | `false` | Whether to allow negative numbers. |
| `fixNumber` | `bool` | `true` | Inserts `0` before a leading decimal point, and `0` after a trailing decimal point. |
| `insertDecimalPoint` | `bool` | `false` | Automatically inserts the decimal point as the user types (e.g. `123` → `1.23`). Requires `decimalDigits` to be set. |
| `insertDecimalDigits` | `bool` | `false` | Always appends decimal digits with zeros (e.g. `5` → `5.00`). Requires `decimalDigits` to be set. |
| `overrideDecimalPoint` | `bool` | `false` | When a second decimal point is typed, moves the decimal point to the new position instead of ignoring it. |
| `prefix` | `String?` | `null` | String prepended to the formatted value (e.g. `'\$ '`). |
| `suffix` | `String?` | `null` | String appended to the formatted value (e.g. `' USD'`). |

---

### CurrencyTextInputFormatter

Pre-configured formatter for currency input. Defaults: 2 decimal digits, grouping every 3 digits, decimal point auto-inserted.

```dart
TextField(
  inputFormatters: [
    CurrencyTextInputFormatter(
      prefix: '\$ ',
    ),
  ],
  keyboardType: TextInputType.number,
),
```

#### Parameters

Same as `NumberTextInputFormatter` with these defaults:

| Parameter | Default |
|---|---|
| `decimalDigits` | `2` |
| `groupDigits` | `3` |
| `insertDecimalPoint` | `true` |

---

### PercentageTextInputFormatter

Pre-configured formatter for percentage input. Defaults: max 100, 0 decimal digits, decimal digits always inserted.

```dart
TextField(
  inputFormatters: [
    PercentageTextInputFormatter(
      suffix: '%',
    ),
  ],
  keyboardType: TextInputType.number,
),
```

#### Parameters

Same as `NumberTextInputFormatter` with these defaults:

| Parameter | Default |
|---|---|
| `integerDigits` | `3` (minimum `3`) |
| `decimalDigits` | `0` |
| `insertDecimalDigits` | `true` |

The `maxValue` is automatically computed from `integerDigits` and `decimalDigits` (e.g. `integerDigits: 3` → max `100`).
