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

import 'package:decimal/decimal.dart';

part 'decimal_ext.dart';

String formatNumber(
  Decimal? val, {
  int precision = 0, // 展示精度
  bool showSign = false, //是否展示符号位+
  RoundMode? mode,
  bool cutInvalidZero = false, //删除尾部零
  bool showCompact = false, // 是否使用精简转换器转换大数展示, 优先于千分位展示
  CompactConverter? compactConverter, // 自定义精简转换器
  bool showThousands = false, // 是否千分位展示; 优先于正常精度展示
  bool useZeroPadding = false, // 是否使用0来填充小数部分. 例如0.0000123=>0.0{4}123
  String prefix = '', // 前缀
  String suffix = '', // 后缀
  String? defIfZero, // 如果为0时的默认展示
  String defIfNull = '--', // 如果为空或无效值时的默认展示
}) {
  // 处理数据为空的情况
  if (val == null) return defIfNull;

  // 处理数据为0的情况
  if (val == Decimal.zero && defIfZero != null) {
    return defIfZero;
  }

  if (showSign && val >= Decimal.zero) prefix += '+';

  String ret;
  if (showCompact) {
    final (result, unit) = val.compact(
      precision: precision,
      isClean: cutInvalidZero,
      converter: compactConverter,
    );
    ret = result;
    suffix += unit;
  } else if (showThousands) {
    ret = val.thousands(precision, mode: mode, isClean: cutInvalidZero);
  } else {
    ret = val.formatAsString(precision, mode: mode, isClean: cutInvalidZero);
  }

  if (useZeroPadding) {
    ret = ret.zeroPadding;
  }

  return '$prefix$ret$suffix';
}

/// 百分比
String formatPercentage(
  Decimal? val, {
  int precision = 2,
  bool showSign = false,
  RoundMode mode = RoundMode.floor,
  bool cutInvalidZero = false,
  String suffix = '%',
  String defIfNull = '-%', // 如果为空或无效值时的默认展示.
}) {
  if (val == null) return defIfNull;
  return formatNumber(
    val * hundred,
    precision: precision,
    mode: mode,
    showSign: showSign,
    cutInvalidZero: cutInvalidZero,
    suffix: suffix,
    defIfNull: defIfNull,
  );
}

/// 格式化价钱
String formatPrice(
  Decimal? val, {
  int precision = 2,
  RoundMode mode = RoundMode.floor,
  bool cutInvalidZero = true,
  bool showThousands = true,
  bool useZeroPadding = true,
  String prefix = '',
  String suffix = '',
  String? defIfZero,
}) {
  return formatNumber(
    val,
    precision: precision,
    mode: mode,
    cutInvalidZero: cutInvalidZero,
    showThousands: showThousands,
    useZeroPadding: useZeroPadding,
    prefix: prefix,
    suffix: suffix,
    defIfZero: defIfZero,
  );
}

/// 格式化数量
String formatAmount(
  Decimal? val, {
  int precision = 2,
  RoundMode? mode,
  bool showCompact = true,
  CompactConverter? compactConverter,
  bool cutInvalidZero = true,
  bool useZeroPadding = false,
  String prefix = '',
  String suffix = '',
  String? defIfZero,
}) {
  return formatNumber(
    val,
    precision: precision,
    mode: mode,
    showCompact: showCompact,
    compactConverter: compactConverter,
    cutInvalidZero: cutInvalidZero,
    useZeroPadding: useZeroPadding,
    prefix: prefix,
    suffix: suffix,
    defIfZero: defIfZero,
  );
}
