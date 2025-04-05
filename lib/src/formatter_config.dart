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

part of 'format_number_util.dart';

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

typedef CompactConverter = (Decimal, String) Function(Decimal value);

typedef ShrinkZeroConverter = String Function(int zeroCounts);

enum RoundMode {
  round,
  floor,
  ceil,
  truncate,
}

/// 显式定向隔离格式字符（Isolates）
const uniLRI = '\u2066';
const uniRLI = '\u2067';
const uniFSI = '\u2068';
const uniPDI = '\u2069'; // 结束隔离区

/// 显式定向嵌入和覆盖格式字符（Embeddings & Overrides）
const uniLRE = '\u202A';
const uniRLE = '\u202B';
const uniLRO = '\u202D';
const uniRLO = '\u202E';
const uniPDF = '\u202C'; // 嵌套/覆盖结束符

/// https://unicode.org/reports/tr9
/// 为何建议使用隔离字符？
/// 1. 避免嵌套问题
///   隔离字符无需严格匹配起始和结束标记，而嵌入字符必须通过 PDF 精确关闭，否则可能导致文本混乱。
/// 2. 安全性
///   隔离字符的独立作用域可有效防御双向文本攻击（如利用 RLO 反转文件名欺骗用户）。
/// 3. 兼容性与简洁性
///   隔离字符是 Unicode 标准推荐的现代方法，而嵌入字符是遗留方法，未来可能被废弃。
///
/// 使用注意事项:
/// 1. 优先使用隔离字符（LRI/RLI/FSI + PDI）：安全、简单、无嵌套风险。
/// 2. 仅在特殊需求时使用覆盖字符（如必须反转数字方向）。
/// 3. 避免使用嵌入字符（LRE/RLE + PDF）：存在安全性和复杂性隐患。
enum ExplicitDirection {
  /// Explicit Directional Isolates
  /// Treat the following text as isolated and left-to-right.
  /// 将以下文本视为孤立的和从左到右的文本。
  lri(uniLRI, uniPDI),

  /// Treat the following text as isolated and right-to-left.
  /// 将以下文本视为孤立的和从右到左的文本。
  rli(uniRLI, uniPDI),

  ///Treat the following text as isolated and in the direction of its first strong directional character that is not inside a nested isolate.
  /// 将以下文本视为孤立文本，并沿其第一个强方向字符的方向处理，该字符不在嵌套隔离文本内。
  fsi(uniFSI, uniPDI),

  /// Explicit Directional Embeddings
  /// Treat the following text as embedded left-to-right.
  /// 将以下文本视为从左到右嵌入的文本。
  lre(uniLRE, uniPDF),

  /// Treat the following text as embedded right-to-left.
  /// 将以下文本视为从右到左嵌入的文本。
  rle(uniRLE, uniPDF),

  /// Explicit Directional Overrides
  /// Force following characters to be treated as strong left-to-right characters.
  /// 强制将跟随字符视为从左到右的强字符。
  lro(uniLRO, uniPDF),

  /// Force following characters to be treated as strong right-to-left characters.
  /// 强制将跟随字符视为从右到左的强字符。
  rlo(uniRLO, uniPDF);

  final String startCode;
  final String endCode;

  const ExplicitDirection(this.startCode, this.endCode);

  String apply(String content) {
    return '$startCode$content$endCode';
  }
}

/// 多零收缩模式
enum ShrinkZeroMode {
  subscript, // 0.0000123=>0.0₄123
  superscript, // 0.0000123=>0.0⁴123
  curlyBraces, // 0.0000123=>0.0{4}123
  parentheses, // 0.0000123=>0.0(4)123
  squareBrackets, // 0.0000123=>0.0[4]123
  custom; // custom mode.
}

final one = Decimal.one;
final two = Decimal.fromInt(2);
final three = Decimal.fromInt(3);
final twentieth = (Decimal.one / Decimal.fromInt(20)).toDecimal();
final fifty = Decimal.fromInt(50);
final hundred = Decimal.ten.pow(2).toDecimal();
final thousand = Decimal.ten.pow(3).toDecimal();
final tenThousand = Decimal.ten.pow(4).toDecimal();
final million = Decimal.ten.pow(6).toDecimal();
final hundredMillion = Decimal.ten.pow(8).toDecimal();
final billion = Decimal.ten.pow(9).toDecimal();
final tenBillion = Decimal.ten.pow(10).toDecimal();
final trillion = Decimal.ten.pow(12).toDecimal();
final defaultExponentMinDecimal = Decimal.ten.pow(-15).toDecimal();
final defaultExponentMaxDecimal = Decimal.ten.pow(21).toDecimal();

abstract interface class FlexiFormatter {
  /// Global configuration for explicit direction, default null.
  static ExplicitDirection? _globalExplicitDirection;
  static ExplicitDirection? get globalExplicitDirection => _globalExplicitDirection;

  /// Global configuration for shrink zero mode, default null.
  static ShrinkZeroMode? _globalShrinkZeroMode;
  static ShrinkZeroMode? get globalShrinkZeroMode => _globalShrinkZeroMode;

  /// Global configuration for shrink zero custom converter, default null.
  static ShrinkZeroConverter? _globalShrinkZeroConverter;
  static ShrinkZeroConverter? get globalShrinkZeroConverter => _globalShrinkZeroConverter;

  /// Global configuration for decimal point, default [defaultDecimalSeparator].
  static String _globalDecimalSeparator = defaultDecimalSeparator;
  static String get globalDecimalSeparator => _globalDecimalSeparator;

  /// Global configuration for separator of grouping integer parts, default [defaultGroupIntegerSeparator].
  static String _globalGroupIntegerSeparator = defaultGroupIntegerSeparator;
  static String get globalGroupIntegerSeparator => _globalGroupIntegerSeparator;

  /// Global configuration for count of grouping integer parts, default [defaultGroupIntegerCounts].
  static int _globalGroupIntegerCounts = defaultGroupIntegerCounts;
  static int get globalGroupIntegerCounts => _globalGroupIntegerCounts;

  /// Global configuration for compact formatting. default [toThousandCompact] will be used
  static CompactConverter _globalCompactConverter = (Decimal value) => value.toThousandCompact;
  static CompactConverter get globalCompactConverter => _globalCompactConverter;

  /// Global configuration for displayed as the minimum boundary value of the exponent.
  static Decimal _exponentMinDecimal = Decimal.ten.pow(-15).toDecimal();
  static Decimal get exponentMinDecimal => _exponentMinDecimal;

  /// Global configuration for displayed as the maximum boundary value of the exponent
  static Decimal _exponentMaxDecimal = Decimal.ten.pow(21).toDecimal();
  static Decimal get exponentMaxDecimal => _exponentMaxDecimal;

  static void restoreDefaultConfig() {
    _globalExplicitDirection = null;
    _globalShrinkZeroMode = null;
    _globalShrinkZeroConverter = null;
    _globalDecimalSeparator = defaultDecimalSeparator;
    _globalGroupIntegerSeparator = defaultGroupIntegerSeparator;
    _globalGroupIntegerCounts = defaultGroupIntegerCounts;
    _globalCompactConverter = (Decimal value) => value.toThousandCompact;
    _exponentMinDecimal = defaultExponentMinDecimal;
    _exponentMaxDecimal = defaultExponentMaxDecimal;
  }

  static FlexiFormatter get configureWith => _$FlexiFormatterConfigurator();

  void call({
    ExplicitDirection? direction,
    ShrinkZeroMode? shrikMode,
    String decimalSeparator,
    String groupSeparator,
    int groupCounts,
    CompactConverter compactConverter,
    ShrinkZeroConverter? shrinkZeroConverter,
    Decimal exponentMinDecimal,
    Decimal exponentMaxDecimal,
  });

  /// Simplified Chinese compact conversion
  static (Decimal, String) simplifiedChineseCompactConverter(Decimal value) =>
      value.toSimplifiedChineseCompact;

  /// Traditional Chinese compact conversion
  static (Decimal, String) traditionalChineseCompactConverter(Decimal value) =>
      value.toTraditionalChineseCompact;
}

final class _$FlexiFormatterConfigurator implements FlexiFormatter {
  const _$FlexiFormatterConfigurator();

  @override
  void call({
    Object? direction = _placeHolder,
    Object? shrikMode = _placeHolder,
    Object? decimalSeparator = _placeHolder,
    Object? groupSeparator = _placeHolder,
    Object? groupCounts = _placeHolder,
    Object? compactConverter = _placeHolder,
    Object? shrinkZeroConverter = _placeHolder,
    Object? exponentMinDecimal,
    Object? exponentMaxDecimal,
  }) {
    if (direction != _placeHolder && (direction == null || direction is ExplicitDirection)) {
      FlexiFormatter._globalExplicitDirection = direction as ExplicitDirection?;
    }

    if (shrikMode != _placeHolder && (shrikMode == null || shrikMode is ShrinkZeroMode)) {
      FlexiFormatter._globalShrinkZeroMode = shrikMode as ShrinkZeroMode?;
    }

    if (shrinkZeroConverter != _placeHolder &&
        (shrinkZeroConverter == null || shrinkZeroConverter is ShrinkZeroConverter)) {
      FlexiFormatter._globalShrinkZeroConverter = shrinkZeroConverter as ShrinkZeroConverter?;
    }

    if (decimalSeparator != _placeHolder &&
        decimalSeparator is String &&
        decimalSeparator.isNotEmpty) {
      FlexiFormatter._globalDecimalSeparator = decimalSeparator;
    }

    if (groupSeparator != _placeHolder && groupSeparator is String && groupSeparator.isNotEmpty) {
      FlexiFormatter._globalGroupIntegerSeparator = groupSeparator;
    }

    if (groupCounts != _placeHolder && groupCounts is int) {
      FlexiFormatter._globalGroupIntegerCounts = groupCounts.clamp(1, maxGroupIntegerCounts);
    }

    if (compactConverter != _placeHolder && compactConverter is CompactConverter) {
      FlexiFormatter._globalCompactConverter = compactConverter;
    }

    if (exponentMinDecimal != _placeHolder &&
        exponentMinDecimal is Decimal &&
        exponentMinDecimal < defaultExponentMinDecimal) {
      FlexiFormatter._exponentMinDecimal = exponentMinDecimal;
    }

    if (exponentMaxDecimal != _placeHolder &&
        exponentMaxDecimal is Decimal &&
        exponentMaxDecimal > defaultExponentMaxDecimal) {
      FlexiFormatter._exponentMaxDecimal = exponentMaxDecimal;
    }
  }
}

const _placeHolder = _$FlexiFormatterPlaceholder();

final class _$FlexiFormatterPlaceholder {
  const _$FlexiFormatterPlaceholder();
}
