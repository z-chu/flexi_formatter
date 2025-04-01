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

// 上角标的数字符号12345⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻
const superscriptNumerals = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

// 上角标的正负号
const superscriptPositive = '⁺';
const superscriptNegative = '⁻';

// 下角标的数字符号12345₀₁₂₃₄₅₆₇₈₉₊₋
const subscriptNumerals = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

// 下角标的正负号
const subscriptPositive = '₊';
const subscriptNegative = '₋';

// 默认Decimal除法精度
const int defaultScaleOnInfinitePrecision = 17;

typedef CompactConverter = (Decimal, String) Function(Decimal);

enum RoundMode {
  round,
  floor,
  ceil,
  truncate,
}

enum UnicodeDirection {
  ltr,
  rtl;
}

enum ShrinkZeroMode {
  compact, // 0.0000123=>0.0{4}123
  subscript, // 0.0000123=>0.0₄123
  superscript; // 0.0000123=>0.0⁴123
}

extension StringExt on String {
  Decimal? get decimal => Decimal.tryParse(this);
  Decimal get d => Decimal.tryParse(this) ?? Decimal.zero;

  String get cleanedString => cleaned;

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

final Decimal two = Decimal.fromInt(2);
final Decimal three = Decimal.fromInt(3);
final Decimal twentieth = (Decimal.one / Decimal.fromInt(20)).toDecimal();
final Decimal fifty = Decimal.fromInt(50);
final Decimal hundred = Decimal.fromInt(100);

extension FormatDecimal on Decimal {
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

  /// Global configuration for decimal point default [decimalSeparator].
  static String decimalSeparator = '.';

  /// Global configuration for xThousand formatting default [thousandSeparator].
  static String thousandSeparator = ',';

  /// Global configuration for compact formatting. if null, The [defaultCompactConverter] will be used
  static CompactConverter? globalCompactConverter;

  /// Default compact conversion
  static (Decimal, String) defaultCompactConverter(Decimal value) => value.toThousandCompact;

  /// Simplified Chinese compact conversion
  static (Decimal, String) simplifiedChineseCompactConverter(Decimal value) =>
      value.toSimplifiedChineseCompact;

  /// Traditional Chinese compact conversion
  static (Decimal, String) traditionalChineseCompactConverter(Decimal value) =>
      value.toTraditionalChineseCompact;

  /// Global configuration for displayed as the minimum boundary value of the exponent.
  static Decimal exponentMinDecimal = Decimal.ten.pow(-15).toDecimal();

  /// Global configuration for displayed as the maximum boundary value of the exponent
  static Decimal exponentMaxDecimal = Decimal.ten.pow(21).toDecimal();

  /// Format this number with thousands separators
  /// If [precision] is not specified, it defaults to 3.
  (String, String) compact({
    int precision = 2,
    bool isClean = true,
    RoundMode? mode,
    CompactConverter? converter,
  }) {
    converter ??= globalCompactConverter ?? defaultCompactConverter;
    var (value, unit) = converter(this);
    if (mode != null) value = value.toRoundMode(mode, scale: precision);
    String result = value.toStringAsFixed(precision);
    if (isClean) result = result.cleaned;
    return (result, unit);
  }

  /// use [RoundMode] to handling Decimal
  Decimal toRoundMode(RoundMode mode, {int? scale}) {
    Decimal val = this;
    scale ??= 0;
    switch (mode) {
      case RoundMode.round:
        val = val.round(scale: scale);
        break;
      case RoundMode.floor:
        val = val.floor(scale: scale);
        break;
      case RoundMode.ceil:
        val = val.ceil(scale: scale);
        break;
      case RoundMode.truncate:
        val = val.truncate(scale: scale);
        break;
    }
    return val;
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
    RoundMode? mode,
    bool isClean = true,
  }) {
    Decimal val = this;
    if (mode != null) val = toRoundMode(mode, scale: precision);
    String result;
    if (val.abs() <= exponentMinDecimal || val.abs() > exponentMaxDecimal) {
      result = val.toStringAsExponential(precision);
    } else {
      result = val.toStringAsFixed(precision);
    }
    if (isClean) result = result.cleaned;
    return result;
  }

  /// Parsing [Decimal] to percentage [String].
  String get percentage => '${(this * hundred).toStringAsFixed(2).cleaned}%';

  /// Parsing Decimal to thousands [String].
  String thousands(
    int precision, {
    RoundMode? mode,
    bool isClean = true,
    String? separator,
  }) {
    return formatAsString(
      precision,
      mode: mode,
      isClean: isClean,
    ).thousands(separator ?? thousandSeparator);
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
      String value when value.endsWith(FormatDecimal.decimalSeparator) =>
        value.substring(0, value.length - 1),
      String value when value.endsWith('0') && contains(FormatDecimal.decimalSeparator) =>
        value.substring(0, value.length - 1).cleaned,
      String value when value.contains('e') => value.replaceAll(RegExp(r'(?<=\.\d*?)0+(?!\d)'), ''),
      _ => this,
    };
  }

  String thousands(String separator) {
    final dotIndex = indexOf(FormatDecimal.decimalSeparator);
    String integerPart, decimalPart;
    if (dotIndex == -1) {
      integerPart = this;
      decimalPart = '';
    } else {
      integerPart = substring(0, dotIndex);
      decimalPart = substring(dotIndex, length);
    }
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final formattedInteger = integerPart.replaceAllMapped(
      regex,
      (Match match) => '${match[1]}$separator',
    );

    return formattedInteger + decimalPart;
  }

  String shrinkZero(ShrinkZeroMode mode) {
    final dotIndex = lastIndexOf(FormatDecimal.decimalSeparator);
    if (dotIndex == -1) return this;

    final decimalPart = substring(dotIndex + 1);
    final regex = RegExp(r'(0{4,})(?=[1-9]|$)');
    final formattedDecimal = decimalPart.replaceAllMapped(
      regex,
      (Match match) {
        final zeroLen = match[1]!.length;
        return switch (mode) {
          ShrinkZeroMode.compact => '0{$zeroLen}',
          ShrinkZeroMode.subscript => '0${zeroLen.subscriptNumeral}',
          ShrinkZeroMode.superscript => '0${zeroLen.superscriptNumeral}'
        };
      },
    );

    return '${substring(0, dotIndex)}${FormatDecimal.decimalSeparator}$formattedDecimal';
  }
}
