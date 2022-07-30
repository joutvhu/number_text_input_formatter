part of 'formatter.dart';

const CODE_COMMA = 44;
const CODE_DOT = 46;
const CODE_0 = 48;
const CODE_1 = 49;
const CODE_2 = 50;
const CODE_3 = 51;
const CODE_4 = 52;
const CODE_5 = 53;
const CODE_6 = 54;
const CODE_7 = 55;
const CODE_8 = 56;
const CODE_9 = 57;

class TextNumberFilter {
  final NumberTextInputFormatter options;
  final TextValueEditor state;

  bool hasDecimalPoint = true;
  bool allowDecimalPoint = true;
  bool removing = false;
  int? maxIntegerDigits;
  int? maxDecimalDigits;

  bool allowing = true;
  int deleted = 0;
  int regionStart = 0;
  int regionEnd = 0;
  int integerDigits = 0;
  int? decimalPointAt;
  int decimalDigits = 0;
  bool numberStarted = false;
  bool hasNumber = false;
  bool decimalOnlyZero = false;
  bool foundNumbers = false;
  bool foundDecimalPoint = false;

  TextNumberFilter(this.options, this.state);

  TextNumberFilter setup({
    bool isRemoving = false,
  }) {
    removing = isRemoving;
    hasDecimalPoint = options.decimalDigits == null || options.decimalDigits! > 0;
    allowDecimalPoint = options.addDecimalDigits || !options.insertDecimalPoint;
    maxIntegerDigits = options.integerDigits;
    maxDecimalDigits = options.decimalDigits;
    if (hasDecimalPoint && !allowDecimalPoint) {
      if (maxIntegerDigits != null && maxDecimalDigits != null) {
        maxIntegerDigits = maxIntegerDigits! + maxDecimalDigits!;
      } else {
        maxIntegerDigits = null;
      }
      maxDecimalDigits = 0;
    }
    return this;
  }

  TextValueEditor filter() {
    String textValue = state.text;
    int length = textValue.length;

    for (int i = 0; i < length; i++) {
      String char = textValue[i];
      bool allow = false;
      if (!numberStarted && options.allowNegative && '-' == char) {
        allow = true;
      } else if (!foundDecimalPoint) {
        if (RegExp('[0-9]').hasMatch(char)) {
          allow = filterInteger(char, i);
        } else if ('.' == char) {
          allow = filterDecimalPoint(char, i);
        }
      } else {
        if (RegExp('[0-9]').hasMatch(char)) {
          allow = filterDecimal(char, i);
        } else if ('.' == char) {
          allow = filterOtherDecimalPoint(char, i);
        }
      }
      if (allow && !numberStarted) {
        numberStarted = true;
      }

      if (allowing != allow) {
        if (regionStart != regionEnd) {
          if (!allowing) {
            state.remove(regionStart - deleted, regionEnd - deleted);
            deleted += regionEnd - regionStart;
          }
        }
        regionStart = i;
        allowing = allow;
      }
      regionEnd = i + 1;
    }

    if (regionStart != regionEnd && !allowing) {
      state.remove(regionStart - deleted, regionEnd - deleted);
    }
    if (hasNumber && integerDigits == 0) {
      state.prefix('0');
    }

    insertValueAfterFilter();

    return state;
  }

  bool filterInteger(String char, int index) {
    hasNumber = true;
    if (char != '0') foundNumbers = true;
    if (foundNumbers) {
      integerDigits++;
      if (maxIntegerDigits == null || integerDigits <= maxIntegerDigits!) {
        return true;
      } else {
        return filterOverInteger(char, index);
      }
    }
    return false;
  }

  bool filterOverInteger(String char, int index) {
    return false;
  }

  bool filterDecimalPoint(String char, int index) {
    if (hasDecimalPoint && allowDecimalPoint) {
      if (integerDigits == 0) {
        integerDigits++;
        if (!allowing && regionStart != regionEnd) {
          state.remove(regionStart - deleted, regionEnd - deleted);
          deleted += regionEnd - regionStart;
        }
        state.insert(index - deleted, '0');
        allowing = true;
        deleted--;
        regionStart = index;
        regionEnd = index + 1;
      }
      decimalPointAt = index - deleted;
      foundDecimalPoint = true;
      return true;
    }
    return false;
  }

  bool filterDecimal(String char, int index) {
    decimalDigits++;
    if (maxDecimalDigits == null || decimalDigits <= maxDecimalDigits!) {
      if (!decimalOnlyZero || char == '0') {
        return true;
      }
    }
    return false;
  }

  bool filterOtherDecimalPoint(String char, int index) {
    var allow = false;
    if (hasDecimalPoint && allowDecimalPoint && options.overrideDecimalPoint) {
      if (!allowing && regionStart != regionEnd) {
        state.remove(regionStart - deleted, regionEnd - deleted);
        deleted += regionEnd - regionStart;
      }
      if (decimalPointAt! < index - deleted - 1) {
        state.remove(decimalPointAt!, decimalPointAt! + 1);
        deleted++;
        decimalPointAt = index - deleted;
        if (decimalPointAt! > 1 && state.at(0) == '0') {
          state.remove(0, 1);
          deleted++;
          decimalPointAt = decimalPointAt! - 1;
        }
        if (maxIntegerDigits != null && maxIntegerDigits! < decimalPointAt!) {
          state.remove(maxIntegerDigits!, decimalPointAt!);
          deleted += decimalPointAt! - maxIntegerDigits!;
          decimalPointAt = maxIntegerDigits!;
        }
        integerDigits = state.length;
        decimalDigits = 0;
        allow = true;
      }
      foundDecimalPoint = true;
      regionStart = index;
      regionEnd = index + 1;
      allowing = allow;
    }
    return allow;
  }

  void insertValueAfterFilter() {
    if (foundDecimalPoint) {
      if (decimalDigits == 0) {
        insertDecimalDigits();
      }
    } else {
      if (hasDecimalPoint) {
        insertDecimalPoint();
      }
    }
  }

  void insertDecimalDigits() {
    if (!removing) {
      var insertDigits = options.integerDigits ?? 1;
      state.suffix('0' * insertDigits);
    }
  }

  void insertDecimalPoint() {
    if (options.addDecimalDigits) {
      if (!removing) {
        state.suffix('.${'0' * options.decimalDigits!}');
      }
    } else if (options.insertDecimalPoint) {
      if (state.length > options.decimalDigits!) {
        state.insert(state.length - options.decimalDigits!, '.');
      } else {
        if (!removing || state.length > 1 || (state.length == 1 && state[0] != CODE_0)) {
          var missingNumber = options.decimalDigits! - state.length;
          var missingInteger = '0.';
          if (missingNumber > 0) {
            missingInteger += '0' * missingNumber;
          }
          state.prefix(missingInteger);
        }
      }
    }
  }
}

class TextPercentageFilter extends TextNumberFilter {
  TextPercentageFilter(
      PercentageTextInputFormatter options,
      TextValueEditor state,
      ) : super(options, state);

  @override
  bool filterOverInteger(String char, int index) {
    if (!decimalOnlyZero && char == '0') {
      // UTF-16 code: 48 = 0, 49 = 1
      if (index - deleted == 2 && state.codeUnits[0] == 49 && state.codeUnits[1] == 48) {
        decimalOnlyZero = true;
        return true;
      }
    }
    return false;
  }
}
