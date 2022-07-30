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

  bool allowing = true;
  int startPosition = 0;
  int integerDigits = 0;
  int? decimalPointAt;
  int decimalDigits = 0;
  bool limitedNumber = false;
  bool limitedDecimal = false;
  bool numberStarted = false;
  bool hasNumber = false;
  bool foundNumbers = false;

  TextNumberFilter(this.options, this.editor);

  bool get foundDecimalPoint => decimalPointAt != null;

  TextNumberFilter setup({
    bool isRemoving = false,
  }) {
    removing = isRemoving;
    hasDecimalPoint = options.decimalDigits == null || options.decimalDigits! > 0;
    allowDecimalPoint = options.addDecimalDigits || !options.insertDecimalPoint;
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
    return this;
  }

  TextValueEditor filter() {
    editor.forEach((value, index, state) {
      bool allow = false;
      if (!numberStarted && options.allowNegative && value == _negative) {
        allow = true;
      } else if (!foundDecimalPoint) {
        if (_number_0 <= value && value <= _number_9) {
          allow = filterInteger(value, state.index, state);
        } else if (value == _dot) {
          allow = filterDecimalPoint(value, state.index, state);
        }
      } else {
        if (_number_0 <= value && value <= _number_9) {
          allow = filterDecimal(value, state.index, state);
        } else if (value == _dot) {
          allow = filterOtherDecimalPoint(value, state.index, state);
        }
      }
      if (allow && !numberStarted) {
        numberStarted = true;
      }

      if (allowing != allow || state.index == state.length) {
        if (!allowing && startPosition < state.index) {
          state.remove(startPosition, state.index);
        }
        startPosition = state.index;
        allowing = allow;
      }
      return true;
    });

    if (!allowing && startPosition < editor.length) {
      editor.remove(startPosition, editor.length);
    }
    if (hasNumber && integerDigits == 0) {
      editor.prefix('0');
    }

    insertValueAfterFilter();

    return editor;
  }

  bool filterInteger(int value, int index, LookupTextValueEditor state) {
    hasNumber = true;
    if (value != _number_0) foundNumbers = true;
    if (foundNumbers) {
      integerDigits++;
      if (maxIntegerDigits == null || integerDigits < maxIntegerDigits!) {
        return true;
      } else if (maxIntegerDigits != null && integerDigits == maxIntegerDigits!) {
        if (options.maxInteger != null && options.maxInteger!.length == maxIntegerDigits) {
          var codes = options.maxInteger!.codeUnits;
          for (int i = 0; i < maxIntegerDigits!; i++) {
            var code = codes[i];
            var char = state[i];
            if (char < code) {
              return true;
            } else if (char > code) {
              return false;
            }
          }
          limitedNumber = true;
          return true;
        } else {
          return true;
        }
      } else {
        return filterOverInteger(value, state.index, state);
      }
    }
    return false;
  }

  bool filterOverInteger(int value, int index, LookupTextValueEditor state) {
    return false;
  }

  bool filterDecimalPoint(int value, int index, LookupTextValueEditor state) {
    if (hasDecimalPoint && allowDecimalPoint) {
      if (integerDigits == 0) {
        integerDigits++;
        if (!allowing && startPosition < state.index) {
          state.remove(startPosition, state.index);
        }
        state.prefix('0');
        allowing = true;
        startPosition = state.index;
      }
      decimalPointAt = state.index;
      return true;
    }
    return false;
  }

  bool filterDecimal(int value, int index, LookupTextValueEditor state) {
    decimalDigits++;
    if (maxDecimalDigits == null || decimalDigits <= maxDecimalDigits!) {
      if (maxDecimalDigits == null || value == _number_0) {
        return true;
      } else if (limitedDecimal) {
        return false;
      } else if (limitedNumber && options.maxDecimal != null && options.maxDecimal!.length == maxDecimalDigits) {
        var codes = options.maxDecimal!.codeUnits;
        var char = codes[state.index - decimalPointAt! - 1];
        if (value < char) {
          limitedNumber = false;
          return true;
        } else if (value > char) {
          limitedDecimal = true;
          return false;
        } else {
          return true;
        }
      } else {
        limitedNumber = false;
        return true;
      }
    }
    return false;
  }

  bool filterOtherDecimalPoint(int value, int index, LookupTextValueEditor state) {
    var allow = false;
    if (hasDecimalPoint && allowDecimalPoint && options.overrideDecimalPoint) {
      if (!allowing && startPosition < state.index) {
        state.remove(startPosition, state.index);
      }
      if (decimalPointAt! < state.index - 1) {
        // If the text cursor is after the dot, it takes precedence.
        if (state.selection?.base == null ||
            state.selection?.base != state.selection?.extent ||
            state.selection?.base != decimalPointAt! + 1) {
          // Change decimal point.
          state.remove(decimalPointAt!, decimalPointAt! + 1);
          decimalPointAt = state.index;
          if (decimalPointAt! > 1 && state[0] == _number_0) {
            state.remove(0, 1);
            decimalPointAt = decimalPointAt! - 1;
          }
          if (maxIntegerDigits != null && maxIntegerDigits! < decimalPointAt!) {
            state.remove(maxIntegerDigits!, decimalPointAt!);
            decimalPointAt = maxIntegerDigits!;
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
      var insertDigits = options.decimalDigits ?? 1;
      editor.suffix('0' * insertDigits);
    }
  }

  void insertDecimalPoint() {
    if (options.addDecimalDigits) {
      if (!removing) {
        editor.suffix('.${'0' * options.decimalDigits!}');
      }
    } else if (options.insertDecimalPoint) {
      if (editor.length > options.decimalDigits!) {
        editor.insert(editor.length - options.decimalDigits!, '.');
      } else {
        if (!removing || editor.length > 1 || (editor.length == 1 && editor[0] != _number_0)) {
          var missingNumber = options.decimalDigits! - editor.length;
          var missingInteger = '0.';
          if (missingNumber > 0) {
            missingInteger += '0' * missingNumber;
          }
          editor.prefix(missingInteger);
        }
      }
    }
  }
}
