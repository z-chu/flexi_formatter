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

/// 默认小数点分隔符
const defaultDecimalSeparator = '.';

/// 默认整数部分分组(千分位)分隔符
const defaultGroupIntegerSeparator = ',';

/// 默认整数部分分组数量计数
const defaultGroupIntegerCounts = 3;

/// 最大可分组计数
const maxGroupIntegerCounts = 10;

/// 上角标的数字符号12345⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻
const superscriptNumerals = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

/// 上角标的正负号
const superscriptPositive = '⁺';
const superscriptNegative = '⁻';

/// 下角标的数字符号12345₀₁₂₃₄₅₆₇₈₉₊₋
const subscriptNumerals = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

/// 下角标的正负号
const subscriptPositive = '₊';
const subscriptNegative = '₋';

/// 默认Decimal除法精度
const int defaultScaleOnInfinitePrecision = 17;

typedef CompactConverter = (Decimal, String) Function(Decimal);

typedef ShrinkZeroConverter = String Function(int zeroCounts);

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

/// 多零收缩模式
enum ShrinkZeroMode {
  custom, // custom mode.
  compact, // 0.0000123=>0.0{4}123
  subscript, // 0.0000123=>0.0₄123
  superscript; // 0.0000123=>0.0⁴123
}

final Decimal two = Decimal.fromInt(2);
final Decimal three = Decimal.fromInt(3);
final Decimal twentieth = (Decimal.one / Decimal.fromInt(20)).toDecimal();
final Decimal fifty = Decimal.fromInt(50);
final Decimal hundred = Decimal.fromInt(100);
final Decimal million = Decimal.ten.pow(6).toDecimal();

abstract interface class FlexiFormatter {
  /// Global configuration for unicode direction, default null.
  static UnicodeDirection? globalUnicodeDirection;

  /// Global configuration for shrink zero mode, default null.
  static ShrinkZeroMode? globalShrinkZeroMode;

  /// Global configuration for shrink zero custom converter, default null.
  static ShrinkZeroConverter? globalShrinkZeroConverter;

  /// Global configuration for decimal point, default [defaultDecimalSeparator].
  static String globalDecimalSeparator = defaultDecimalSeparator;

  /// Global configuration for separator of grouping integer parts, default [defaultGroupIntegerSeparator].
  static String globalGroupIntegerSeparator = defaultGroupIntegerSeparator;

  /// Global configuration for count of grouping integer parts, default [defaultGroupIntegerCounts].
  static int _globalGroupIntegerCounts = defaultGroupIntegerCounts;
  static int get globalGroupIntegerCounts => _globalGroupIntegerCounts;
  static set globalGroupIntegerCounts(int val) {
    _globalGroupIntegerCounts = val.clamp(1, maxGroupIntegerCounts);
  }

  /// Global configuration for compact formatting. default [toThousandCompact] will be used
  static CompactConverter globalCompactConverter = (Decimal value) => value.toThousandCompact;

  /// Simplified Chinese compact conversion
  static CompactConverter simplifiedChineseCompactConverter =
      (Decimal value) => value.toSimplifiedChineseCompact;

  /// Traditional Chinese compact conversion
  static CompactConverter traditionalChineseCompactConverter =
      (Decimal value) => value.toTraditionalChineseCompact;

  /// Global configuration for displayed as the minimum boundary value of the exponent.
  static Decimal exponentMinDecimal = Decimal.ten.pow(-15).toDecimal();

  /// Global configuration for displayed as the maximum boundary value of the exponent
  static Decimal exponentMaxDecimal = Decimal.ten.pow(21).toDecimal();

  static void setGlobalConfig({
    UnicodeDirection? direction,
    ShrinkZeroMode? shrikMode,
    String? decimalSeparator,
    String? groupSeparator,
    int? groupCounts,
    CompactConverter? compactConverter,
    ShrinkZeroConverter? shrinkZeroConverter,
  }) {
    globalUnicodeDirection = direction;
    globalShrinkZeroMode = shrikMode;

    if (decimalSeparator != null && decimalSeparator.isNotEmpty) {
      globalDecimalSeparator = decimalSeparator;
    }

    if (groupSeparator != null && groupSeparator.isNotEmpty) {
      globalGroupIntegerSeparator = groupSeparator;
    }

    if (groupCounts != null) {
      globalGroupIntegerCounts = groupCounts;
    }

    if (compactConverter != null) {
      globalCompactConverter = compactConverter;
    }

    if (shrinkZeroConverter != null) {
      globalShrinkZeroConverter = shrinkZeroConverter;
    }
  }

  static void restoreGlobalDefaultConfig([bool restoreSpecialSetting = true]) {
    /// Global configuration
    globalUnicodeDirection = null;
    globalShrinkZeroMode = null;
    globalDecimalSeparator = defaultDecimalSeparator;
    globalGroupIntegerSeparator = defaultGroupIntegerSeparator;
    globalGroupIntegerCounts = defaultGroupIntegerCounts;
    globalCompactConverter = (Decimal value) => value.toThousandCompact;
    globalShrinkZeroConverter = null;

    /// Global Special Settings
    if (restoreSpecialSetting) {
      simplifiedChineseCompactConverter = (Decimal value) => value.toSimplifiedChineseCompact;
      traditionalChineseCompactConverter = (Decimal value) => value.toTraditionalChineseCompact;
      exponentMinDecimal = Decimal.ten.pow(-15).toDecimal();
      exponentMaxDecimal = Decimal.ten.pow(21).toDecimal();
    }
  }
}
