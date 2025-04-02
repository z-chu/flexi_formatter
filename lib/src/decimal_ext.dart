// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of 'decimal_format_util.dart';

extension StringExt on String {
  Decimal? get decimal => Decimal.tryParse(this);
  Decimal get d => Decimal.tryParse(this) ?? Decimal.zero;

  /// https://unicode.org/reports/tr9/
  /// 从左到右嵌入
  String get ltr => '\u202a$this\u202c';

  /// 从右到左嵌入
  String get rtl => '\u202b$this\u202c';
}

extension BigIntExt on BigInt {
  Decimal get decimal => d;
  Decimal get d => Decimal.fromBigInt(this);
}

extension DoubleExt on double {
  Decimal get decimal => d;
  Decimal get d => Decimal.parse(toString());
}

extension IntExt on int {
  Decimal get decimal => d;
  Decimal get d => Decimal.fromInt(this);

  /// 将数字转换为下角标形式字符展示.
  String get subscriptNumeral {
    if (isNaN) return '';
    final buffer = StringBuffer(sign < 0 ? subscriptNegative : '');
    final zeroCodeUnits = '0'.codeUnitAt(0);
    for (int unit in abs().toString().codeUnits) {
      buffer.write(subscriptNumerals[unit - zeroCodeUnits]);
    }
    return buffer.toString();
  }

  /// 将数字转换为上角标形式字符展示.
  String get superscriptNumeral {
    if (isNaN) return '';
    final buffer = StringBuffer(sign < 0 ? subscriptNegative : '');
    final zeroCodeUnits = '0'.codeUnitAt(0);
    for (int unit in abs().toString().codeUnits) {
      buffer.write(superscriptNumerals[unit - zeroCodeUnits]);
    }
    return buffer.toString();
  }
}

extension DecimalExt on Decimal {
  Decimal get half => (this / two).toDecimal(
        scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
      );

  Decimal divNum(num num) {
    assert(num != 0, 'divisor cannot be zero');
    if (num is int) return div(Decimal.fromInt(num));
    if (num is double) return div(num.d);
    throw Exception('$num cannot convert to decimal');
  }

  Decimal div(Decimal other) {
    assert(other != Decimal.zero, 'divisor cannot be zero');
    return (this / other).toDecimal(
      scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
    );
  }

  /// Format this number with compact converter.
  (String, String) _compact({
    int precision = 2,
    bool isClean = true,
    RoundMode? roundMode,
    CompactConverter? converter,
  }) {
    converter ??= FlexiFormatter.globalCompactConverter;
    var (value, unit) = converter(this);
    if (roundMode != null) value = value.toRoundMode(roundMode, scale: precision);
    String result = value.toStringAsFixed(precision);
    if (isClean) result = result.cleaned;
    return (result, unit);
  }

  /// use [RoundMode] to handling Decimal
  Decimal toRoundMode(RoundMode mode, {int? scale}) {
    scale ??= 0;
    return switch (mode) {
      RoundMode.round => round(scale: scale),
      RoundMode.floor => floor(scale: scale),
      RoundMode.ceil => ceil(scale: scale),
      RoundMode.truncate => truncate(scale: scale),
    };
  }

  /// The rational string that correctly represents this number.
  ///
  /// All [Decimal]s in the range `10^-15` (inclusive) to `10^21` (exclusive)
  /// are converted to their decimal representation with at least one digit
  /// afer the decimal point. For all other decimal, this method returns an
  /// exponential representation (see [toStringAsExponential]).
  ///
  /// [precision] stands for fractionDigits
  String formatAsString(
    int precision, {
    RoundMode? roundMode,
    bool isClean = true,
  }) {
    Decimal val = this;
    if (roundMode != null) val = toRoundMode(roundMode, scale: precision);
    String result;
    if (val.abs() <= FlexiFormatter.exponentMinDecimal ||
        val.abs() > FlexiFormatter.exponentMaxDecimal) {
      result = val.toStringAsExponential(precision);
    } else {
      result = val.toStringAsFixed(precision);
    }
    if (isClean) result = result.cleaned;
    return result;
  }

  /// Parsing [Decimal] to percentage [String].
  String get percentage => '${(this * hundred).toStringAsFixed(2).cleaned}%';

  /// Format the integer part of Decimal with grouping configuration
  (String, String) _group(
    int precision, {
    RoundMode? roundMode,
    bool isClean = true,
    int? groupCounts,
    String? groupSeparator,
  }) {
    return formatAsString(
      precision,
      roundMode: roundMode,
      isClean: isClean,
    ).grouping(groupSeparator, groupCounts);
  }
}

extension on Decimal {
  static final trillionDecimal = Decimal.ten.pow(12).toDecimal();
  static final billionDecimal = Decimal.ten.pow(9).toDecimal();
  static final millionDecimal = Decimal.ten.pow(6).toDecimal();
  static final thousandDecimal = Decimal.ten.pow(3).toDecimal();

  (Decimal, String) get toThousandCompact {
    final val = abs();
    if (val >= trillionDecimal) {
      return (
        (this / trillionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        'T',
      );
    } else if (val >= billionDecimal) {
      return (
        (this / billionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        'B',
      );
    } else if (val >= millionDecimal) {
      return (
        (this / millionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        'M',
      );
    } else if (val >= thousandDecimal) {
      return (
        (this / thousandDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        'K',
      );
    } else {
      return (this, '');
    }
  }

  static final hundredBillionDecimal = Decimal.ten.pow(12).toDecimal();
  static final hundredMillionDecimal = Decimal.ten.pow(8).toDecimal();
  static final tenThousandDecimal = Decimal.ten.pow(4).toDecimal();

  (Decimal, String) get toSimplifiedChineseCompact {
    final val = abs();
    if (val > hundredBillionDecimal) {
      return (
        (this / hundredBillionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '兆',
      );
    } else if (val > hundredMillionDecimal) {
      return (
        (this / hundredMillionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '亿',
      );
    } else if (val > tenThousandDecimal) {
      return (
        (this / tenThousandDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '万',
      );
    } else {
      return (this, '');
    }
  }

  (Decimal, String) get toTraditionalChineseCompact {
    final val = abs();
    if (val > hundredBillionDecimal) {
      return (
        (this / hundredBillionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '兆',
      );
    } else if (val > hundredMillionDecimal) {
      return (
        (this / hundredMillionDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '億',
      );
    } else if (val > tenThousandDecimal) {
      return (
        (this / tenThousandDecimal).toDecimal(
          scaleOnInfinitePrecision: defaultScaleOnInfinitePrecision,
        ),
        '萬',
      );
    } else {
      return (this, '');
    }
  }
}

extension on String {
  String get cleaned {
    return switch (this) {
      String value when value.endsWith(defaultDecimalSeparator) =>
        value.substring(0, value.length - 1),
      String value when value.endsWith('0') && contains(defaultDecimalSeparator) =>
        value.substring(0, value.length - 1).cleaned,
      String value when value.contains('e') => value.replaceAll(RegExp(r'(?<=\.\d*?)0+(?!\d)'), ''),
      _ => this,
    };
  }

  (String, String) grouping(String? separator, int? groupCounts) {
    separator ??= FlexiFormatter.globalGroupIntegerSeparator;
    groupCounts ??= FlexiFormatter.globalGroupIntegerCounts;
    groupCounts = groupCounts.clamp(1, 10);

    final dotIndex = indexOf(defaultDecimalSeparator);
    String integerPart, decimalPart;
    if (dotIndex == -1) {
      integerPart = this;
      decimalPart = '';
    } else {
      integerPart = substring(0, dotIndex);
      decimalPart = substring(dotIndex, length);
    }
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp('(\\d)(?=(\\d{$groupCounts})+(?!\\d))'),
      (Match match) => '${match[1]}$separator',
    );

    return (formattedInteger, decimalPart);
  }

  String shrinkZero({
    ShrinkZeroMode? shrinkMode,
    ShrinkZeroConverter? shrinkConverter,
  }) {
    shrinkMode ??= FlexiFormatter.globalShrinkZeroMode;
    shrinkConverter ??= FlexiFormatter.globalShrinkZeroConverter;
    // if (shrinkZeroMode == null) return this;

    final dotIndex = lastIndexOf(defaultDecimalSeparator);
    if (dotIndex == -1) return this;

    final decimalPart = substring(dotIndex + 1);
    final formattedDecimal = decimalPart.replaceAllMapped(
      RegExp(r'(0{4,})(?=[1-9]|$)'),
      (Match match) {
        final zeroPart = match[1] ?? '';
        final zeroCounts = zeroPart.length;
        if (zeroCounts < 1) return zeroPart;
        return switch (shrinkMode) {
          ShrinkZeroMode.compact => '0{$zeroCounts}',
          ShrinkZeroMode.subscript => '0${zeroCounts.subscriptNumeral}',
          ShrinkZeroMode.superscript => '0${zeroCounts.superscriptNumeral}',
          _ => shrinkConverter?.call(zeroCounts) ?? zeroPart,
        };
      },
    );

    return '${substring(0, dotIndex)}${FlexiFormatter.globalDecimalSeparator}$formattedDecimal';
  }

  String unicodeDirection(UnicodeDirection? direction) {
    direction ??= FlexiFormatter.globalUnicodeDirection;
    if (direction == null) return this;

    return switch (direction) {
      UnicodeDirection.ltr => ltr,
      UnicodeDirection.rtl => rtl,
    };
  }
}
