part of 'formatter.dart';

const _comma = 44;
const _negative = 45;
const _dot = 46;
const _number_0 = 48;
const _number_1 = 49;
const _number_2 = 50;
const _number_3 = 51;
const _number_4 = 52;
const _number_5 = 53;
const _number_6 = 54;
const _number_7 = 55;
const _number_8 = 56;
const _number_9 = 57;

class TextNumberFilter {
  final NumberTextInputFormatter options;
  final TextValueEditor editor;

  bool hasDecimalPoint = true;
  bool allowDecimalPoint = true;
  bool decimalWithoutPoint = false;
  bool removing = false;
  int? maxIntegerDigits;
  int? maxDecimalDigits;
  String decimalSeparator = '.';
  String groupSeparator = ',';
  bool allowing = true;
  int startPosition = 0;
  int integerDigits = 0;
  int? decimalPoint;
  int decimalDigits = 0;
  bool limitedNumber = false;
  bool limitedInteger = false;
  bool? limitedDecimal;
  bool numberStarted = false;
  bool hasNumber = false;
  bool foundNumbers = false;

  TextNumberFilter(this.options, this.editor);

  TextNumberFilter prepare(Map<String, dynamic> params) {
    removing = params['removing'] == true;
    hasDecimalPoint = options.decimalDigits == null || options.decimalDigits! > 0;
    allowDecimalPoint = options.insertDecimalDigits || !options.insertDecimalPoint;
    decimalWithoutPoint = hasDecimalPoint && !allowDecimalPoint;
    maxIntegerDigits = options.integerDigits;
    maxDecimalDigits = options.decimalDigits;
    if (decimalWithoutPoint) {
      if (maxIntegerDigits != null && maxDecimalDigits != null) {
        maxIntegerDigits = maxIntegerDigits! + maxDecimalDigits!;
      } else {
        maxIntegerDigits = null;
      }
      maxDecimalDigits = 0;
    }
    decimalSeparator = options.decimalSeparator;
    groupSeparator = options.groupSeparator;

    allowing = true;
    startPosition = 0;
    integerDigits = 0;
    decimalPoint = null;
    decimalDigits = 0;
    limitedNumber = false;
    limitedInteger = false;
    limitedDecimal = null;
    numberStarted = false;
    hasNumber = false;
    foundNumbers = false;

    return this;
  }

  TextValueEditor filter() {
    editor.forEach(filterNext, filterComplete);
    afterFilter();
    return editor;
  }

  bool filterNext(int value, int index, LookupTextValueEditor state) {
    bool allow = false;
    if (!numberStarted && options.allowNegative && value == _negative) {
      allow = true;
    } else if (decimalPoint == null) {
      if (_number_0 <= value && value <= _number_9) {
        allow = filterInteger(value, state.index, state);
      } else if (value == decimalSeparator.codeUnitAt(0)) {
        allow = filterDecimalPoint(value, state.index, state);
      }
    } else {
      if (_number_0 <= value && value <= _number_9) {
        allow = filterDecimal(value, state.index, state);
      } else if (value == decimalSeparator.codeUnitAt(0)) {
        allow = filterOtherDecimalPoint(value, state.index, state);
      }
    }
    if (allow && !numberStarted) {
      numberStarted = true;
    }

    if (allowing != allow || state.index == state.length) {
      if (!allowing && startPosition < state.index) {
        if (decimalPoint == state.index) {
          decimalPoint = startPosition;
        }
        state.remove(startPosition, state.index);
      }
      startPosition = state.index;
      allowing = allow;
    }
    return true;
  }

  void filterComplete(int length, LookupTextValueEditor state) {
    if (!allowing && startPosition < length) {
      state.remove(startPosition, length);
    }

    if (hasNumber && integerDigits == 0) {
      integerDigits = 1;
      state.prefix('0');
    }
  }

  bool filterInteger(int value, int index, LookupTextValueEditor state) {
    var allow = false;
    hasNumber = true;
    if (value != _number_0) foundNumbers = true;
    if (foundNumbers && !limitedInteger) {
      var newIntegerDigits = integerDigits + 1;
      if (maxIntegerDigits == null || newIntegerDigits < maxIntegerDigits!) {
        allow = true;
      } else if (maxIntegerDigits != null && newIntegerDigits == maxIntegerDigits!) {
        allow = filterMaximumInteger(value, state.index, state);
      } else {
        allow = filterOverInteger(value, state.index, state);
      }
    }
    if (allow) {
      integerDigits++;
    }
    return allow;
  }

  bool filterMaximumInteger(int value, int index, LookupTextValueEditor state) {
    if (options.maxInteger != null && options.maxInteger!.length == maxIntegerDigits) {
      var codes = options.maxInteger!.codeUnits;
      for (int i = 0; i < maxIntegerDigits!; i++) {
        var code = codes[i];
        var char = !allowing && i >= startPosition ? state[state.index + i - startPosition] : state[i];
        if (char < code) {
          return true;
        } else if (char > code) {
          limitedInteger = true;
          return false;
        }
      }
      limitedNumber = true;
      return true;
    } else {
      return true;
    }
  }

  bool filterOverInteger(int value, int index, LookupTextValueEditor state) {
    return false;
  }

  bool filterDecimalPoint(int value, int index, LookupTextValueEditor state) {
    if (hasDecimalPoint && allowDecimalPoint) {
      if (integerDigits == 0) {
        if (!allowing && startPosition < state.index) {
          state.remove(startPosition, state.index);
        }
        state.prefix('0');
        integerDigits = 1;
        allowing = true;
        startPosition = state.index;
      }
      decimalPoint = state.index;
      return true;
    }
    return false;
  }

  bool filterDecimal(int value, int index, LookupTextValueEditor state) {
    var allow = false;
    if (maxDecimalDigits == null || decimalDigits < maxDecimalDigits!) {
      if (maxDecimalDigits == null) {
        allow = true;
      } else if (limitedDecimal == false) {
        allow = true;
      } else if (limitedDecimal == true) {
        allow = false;
      } else if (limitedNumber && options.maxDecimal != null && options.maxDecimal!.length == maxDecimalDigits) {
        allow = filterMaximumDecimal(value, state.index, state);
      } else {
        allow = true;
      }
    }
    if (allow) {
      decimalDigits++;
    }
    return allow;
  }

  bool filterMaximumDecimal(int value, int index, LookupTextValueEditor state) {
    var codes = options.maxDecimal!.codeUnits;
    var char = codes[state.index - decimalPoint! - 1];
    if (value < char) {
      limitedNumber = false;
      limitedDecimal = false;
      return true;
    } else if (value > char) {
      limitedDecimal = true;
      return false;
    } else {
      return true;
    }
  }

  bool filterOtherDecimalPoint(int value, int index, LookupTextValueEditor state) {
    var allow = false;
    if (hasDecimalPoint && allowDecimalPoint && options.overrideDecimalPoint) {
      if (!allowing && startPosition < state.index) {
        state.remove(startPosition, state.index);
      }
      if (decimalPoint! < state.index - 1) {
        // If the text cursor is after the dot, it takes precedence.
        if (state.selection?.base == null ||
            state.selection?.base != state.selection?.extent ||
            state.selection?.base != decimalPoint! + 1) {
          // Change decimal point.
          state.remove(decimalPoint!, decimalPoint! + 1);
          decimalPoint = state.index;
          if (decimalPoint! > 1 && state[0] == _number_0) {
            state.remove(0, 1);
            decimalPoint = decimalPoint! - 1;
          }
          if (maxIntegerDigits != null && maxIntegerDigits! < decimalPoint!) {
            state.remove(maxIntegerDigits!, decimalPoint!);
            decimalPoint = maxIntegerDigits!;
          }
          integerDigits = state.length;
          decimalDigits = 0;
          allow = true;
        }
      }
      startPosition = state.index;
      allowing = allow;
    }
    return allow;
  }

  void afterFilter() {
    if (editor.isNotEmpty) {
      if (decimalPoint != null) {
        if (decimalDigits == 0) {
          insertDecimalDigits();
        }
      } else {
        if (hasDecimalPoint) {
          insertDecimalPoint();
        }
      }

      groupDigits();
    }
  }

  void insertDecimalDigits() {
    decimalPoint ??= editor.length - 1;
    if (!removing) {
      decimalDigits = options.decimalDigits ?? 1;
      editor.suffix('0' * decimalDigits);
    }
  }

  void insertDecimalPoint() {
    if (options.insertDecimalDigits) {
      if (!removing) {
        decimalPoint = editor.length;
        decimalDigits = options.decimalDigits!;
        editor.suffix('$decimalSeparator${'0' * decimalDigits}');
      }
    } else if (options.insertDecimalPoint) {
      if (editor.length > options.decimalDigits!) {
        decimalPoint = editor.length - options.decimalDigits!;
        integerDigits = decimalPoint!;
        decimalDigits = options.decimalDigits!;
        editor.insert(decimalPoint!, decimalSeparator);
      } else {
        if (!removing || editor.length > 1 || (editor.length == 1 && editor[0] != _number_0)) {
          var missingNumber = options.decimalDigits! - editor.length;
          var missingInteger = '0$decimalSeparator';
          if (missingNumber > 0) {
            missingInteger += '0' * missingNumber;
          }
          integerDigits = 1;
          decimalDigits = options.decimalDigits!;
          decimalPoint = 1;
          editor.prefix(missingInteger);
        }
      }
    }
  }

  void groupDigits() {
    if (options.groupDigits != null) {
      var index = integerDigits;
      while (true) {
        index -= options.groupDigits!;
        if (index < 1) {
          break;
        }
        editor.insert(index, groupSeparator);
      }
    }
  }
}
