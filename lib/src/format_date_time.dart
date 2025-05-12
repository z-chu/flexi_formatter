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

// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:intl/intl.dart';

import 'formatter_config.dart';

enum TimeUnit {
  /// 年
  year(Duration.microsecondsPerDay * 365),

  /// 月
  month(Duration.microsecondsPerDay * 30),

  /// 周
  week(Duration.microsecondsPerDay * 7),

  /// 天
  day(Duration.microsecondsPerDay),

  /// 小时
  hour(Duration.microsecondsPerHour),

  /// 分钟
  minute(Duration.microsecondsPerMinute),

  /// 秒
  second(Duration.microsecondsPerSecond),

  /// 毫秒
  millisecond(Duration.microsecondsPerMillisecond),

  /// 微秒
  microsecond(1);

  final int microseconds;
  const TimeUnit(this.microseconds);
}

extension FlexiDateTimeFormatterStringExt on String {
  /// Convert string to DateTime.
  DateTime? toDateTime() => DateTime.tryParse(this);
}

extension FlexiDateTimeFormatterIntExt on int {
  DateTime get dateTimeInMicrosecond => DateTime.fromMicrosecondsSinceEpoch(this);

  DateTime get dateTimeInMillisecond => DateTime.fromMillisecondsSinceEpoch(this);

  DateTime get dateTimeInSecond => DateTime.fromMillisecondsSinceEpoch(this * 1000);

  String get twoDigits {
    return this < 10 ? '0$this' : toString();
  }
}

/// 日期时间扩展
/// 测试日期: DateTime(2025, 5, 1, 12, 30, 45);
extension FlexiDateTimeFormatterExt on DateTime {
  /// 检查DateTime是否在将来。
  bool get isFuture => isAfter(DateTime.now());

  /// 检查DateTime是否在过去。
  bool get isPast => isBefore(DateTime.now());

  /// 检查DateTime是否设置为本地时间.
  bool get isLocal => !isUtc;

  /// 计算两个日期时间之间的差异
  /// [other] 另一个日期时间
  /// [unit] 差异单位，默认为秒
  num diff(DateTime other, {TimeUnit unit = TimeUnit.second}) {
    final diff = difference(other);
    return switch (unit) {
      TimeUnit.year => diff.inDays / 365,
      TimeUnit.month => diff.inDays / 30,
      TimeUnit.week => diff.inDays / 7,
      TimeUnit.day => diff.inDays,
      TimeUnit.hour => diff.inHours,
      TimeUnit.minute => diff.inMinutes,
      TimeUnit.second => diff.inSeconds,
      TimeUnit.millisecond => diff.inMilliseconds,
      TimeUnit.microsecond => diff.inMicroseconds,
    };
  }

  /// 计算两个日期时间之间的差异并返回格式化的字符串
  /// 主要用于倒计时展示
  String diffToString([DateTime? other, bool showSign = false]) {
    other ??= DateTime.now();
    final diff = difference(other);
    var microseconds = diff.inMicroseconds;
    var sign = "";
    var negative = microseconds < 0;
    if (negative) {
      microseconds = -microseconds;
      if (showSign) sign = "-";
    }

    if (microseconds >= TimeUnit.day.microseconds) {
      final days = microseconds ~/ TimeUnit.day.microseconds;
      microseconds = microseconds.remainder(TimeUnit.day.microseconds);
      final hours = (microseconds % TimeUnit.day.microseconds) ~/ TimeUnit.hour.microseconds;
      return '$sign${days}D ${hours.twoDigits}H';
    } else if (microseconds >= TimeUnit.hour.microseconds) {
      final hours = microseconds ~/ TimeUnit.hour.microseconds;
      microseconds = microseconds.remainder(TimeUnit.hour.microseconds);
      final minutes = (microseconds % TimeUnit.hour.microseconds) ~/ TimeUnit.minute.microseconds;
      return '$sign${hours.twoDigits}:${minutes.twoDigits}';
    } else {
      final minutes = microseconds ~/ TimeUnit.minute.microseconds;
      microseconds = microseconds.remainder(TimeUnit.minute.microseconds);
      final seconds = (microseconds % TimeUnit.minute.microseconds) ~/ TimeUnit.second.microseconds;
      return '$sign${minutes.twoDigits}:${seconds.twoDigits}';
    }
  }

  /// 根据[unit]格式化当前DateTime
  /// [unit] 如果未指定, 返回完整格式
  /// >=1天: 格式化为 yMd: 5/1/2025; 2025年5月1日
  /// >=1分钟: 格式化为 Md_Hm 5/1 12:30; 5月1日 12:30
  /// <1分钟: 格式化为 Hms 12:30:45
  String formatByUnit([TimeUnit? unit]) {
    if (unit == null) {
      // 如未指定单位，则将日期时间格式化为默认格式
      return yMd_Hms;
    } else if (unit.microseconds >= TimeUnit.day.microseconds) {
      return yMd;
    } else if (unit.microseconds >= TimeUnit.minute.microseconds) {
      return Md_Hm;
    } else {
      return Hms;
    }
  }

  String? get currentLocale {
    return FlexiFormatter.currentLocale;
  }

  /// 使用 DateFormat.d 的国际化格式格式化日期
  /// >>> 1
  String get d => DateFormat.d(currentLocale).format(this);

  /// 使用 DateFormat.E 的国际化格式格式化日期
  /// >>> Thu, 周四
  String get E => DateFormat.E(currentLocale).format(this);

  /// 使用 DateFormat.EEEE 的国际化格式格式化日期
  /// >>> Thursday, 星期四
  String get EEEE => DateFormat.EEEE(currentLocale).format(this);

  /// 使用 DateFormat.EEEE 的国际化格式格式化日期
  /// >>> T, 四
  String get EEEEE => DateFormat.EEEEE(currentLocale).format(this);

  /// 使用 DateFormat.LLL 的国际化格式格式化日期
  /// >>> May, 5月
  String get LLL => DateFormat.LLL(currentLocale).format(this);

  /// 使用 DateFormat.LLLL 的国际化格式格式化日期
  /// >>> May, 5月
  String get LLLL => DateFormat.LLLL(currentLocale).format(this);

  /// 使用 DateFormat.M 的国际化格式格式化日期
  /// >>> 5月
  String get M => DateFormat.M(currentLocale).format(this);

  /// 使用 DateFormat.Md 的国际化格式格式化日期
  /// >>> 5/1, 5月1日
  String get Md => DateFormat.Md(currentLocale).format(this);

  /// 使用 DateFormat.MEd 的国际化格式格式化日期
  /// >>> Thu, 5/1, 5月1日, 周四
  String get MEd => DateFormat.MEd(currentLocale).format(this);

  /// 使用 DateFormat.MMM 的国际化格式格式化日期
  /// >>> May, 5月
  String get MMM => DateFormat.MMM(currentLocale).format(this);

  /// 使用 DateFormat.MMMd 的国际化格式格式化日期
  /// >>> May 1, 5月1日
  String get MMMd => DateFormat.MMMd(currentLocale).format(this);

  /// 使用 DateFormat.MMMEd 的国际化格式格式化日期
  /// >>> Thu, 5/1, 5月1日, 周四
  String get MMMEd => DateFormat.MMMEd(currentLocale).format(this);

  /// 使用 DateFormat.MMMM 的国际化格式格式化日期
  /// >>> May, 5月
  String get MMMM => DateFormat.MMMM(currentLocale).format(this);

  /// 使用 DateFormat.MMMMd 的国际化格式格式化日期
  /// >>> May 1, 5月1日
  String get MMMMd => DateFormat.MMMMd(currentLocale).format(this);

  // cSpell: ignore MMMMEEEEd
  /// 使用 DateFormat.MMMMEEEEd 的国际化格式格式化日期
  /// >>> Thursday, May 1, 5月1日, 周四
  String get MMMMEEEEd => DateFormat.MMMMEEEEd(currentLocale).format(this);

  /// 使用 DateFormat.QQQ 的国际化格式格式化日期
  /// >>> Q2, 第二季度
  String get QQQ => DateFormat.QQQ(currentLocale).format(this);

  /// 使用 DateFormat.QQQQ 的国际化格式格式化日期
  /// >>> 2nd quarter, 2025年第二季度
  String get QQQQ => DateFormat.QQQQ(currentLocale).format(this);

  /// 使用 DateFormat.y 的国际化格式格式化日期
  /// >>> 2025
  String get y => DateFormat.y(currentLocale).format(this);

  /// 使用 DateFormat.yM 的国际化格式格式化日期
  /// >>> 5/2025, 2025年5月
  String get yM => DateFormat.yM(currentLocale).format(this);

  /// 使用 DateFormat.yMd 的国际化格式格式化日期
  /// >>> 5/1/2025, 2025年5月1日
  String get yMd => DateFormat.yMd(currentLocale).format(this);

  /// 使用 DateFormat.yMEd 的国际化格式格式化日期
  /// >>> Thu, 5/1/2025, 2025年5月1日, 周四
  String get yMEd => DateFormat.yMEd(currentLocale).format(this);

  /// 使用 DateFormat.yMMM 的国际化格式格式化日期
  /// >>> May 2025, 2025年5月
  String get yMMM => DateFormat.yMMM(currentLocale).format(this);

  /// 使用 DateFormat.yMMMd 的国际化格式格式化日期
  /// >>> May 1, 2025, 2025年5月1日
  String get yMMMd => DateFormat.yMMMd(currentLocale).format(this);

  /// 使用 DateFormat.yMMMEd 的国际化格式格式化日期
  /// >>> Thu, May 1, 2025, 2025年5月1日, 周四
  String get yMMMEd => DateFormat.yMMMEd(currentLocale).format(this);

  /// 使用 DateFormat.yMMMM 的国际化格式格式化日期
  /// >>> May 2025, 2025年5月
  String get yMMMM => DateFormat.yMMMM(currentLocale).format(this);

  /// 使用 DateFormat.yMMMMd 的国际化格式格式化日期
  /// >>> May 1, 2025, 2025年5月1日
  /// >>> 2025年5月1日
  String get yMMMMd => DateFormat.yMMMMd(currentLocale).format(this);

  /// 使用 DateFormat.yMMMMEEEEd 的国际化格式格式化日期
  /// >>> Thursday, May 1, 2025, 2025年5月1日, 周四
  String get yMMMMEEEEd => DateFormat.yMMMMEEEEd(currentLocale).format(this);

  /// 使用 DateFormat.yQQQ 的国际化格式格式化日期
  /// >>> Q2 2025, 2025年第二季度
  String get yQQQ => DateFormat.yQQQ(currentLocale).format(this);

  /// 使用 DateFormat.yQQQQ 的国际化格式格式化日期
  /// >>> 2nd quarter 2025, 2025年第二季度
  String get yQQQQ => DateFormat.yQQQQ(currentLocale).format(this);

  /// 使用 DateFormat.H 的国际化格式格式化日期
  /// >>> 12
  String get H => DateFormat.H(currentLocale).format(this);

  /// 使用 DateFormat.Hm 的国际化格式格式化日期
  /// >>> 12:30
  String get Hm => DateFormat.Hm(currentLocale).format(this);

  /// 使用 DateFormat.Hms 的国际化格式格式化日期
  /// >>> 12:30:45
  String get Hms => DateFormat.Hms(currentLocale).format(this);

  /// 使用 DateFormat.j 的国际化格式格式化日期
  /// >>> 12 PM
  String get j => DateFormat.j(currentLocale).format(this);

  /// 使用 DateFormat.jm 的国际化格式格式化日期
  /// >>> 12:30 PM
  String get jm => DateFormat.jm(currentLocale).format(this);

  /// 使用 DateFormat.jms 的国际化格式格式化日期
  /// >>> 12:30:45 PM
  String get jms => DateFormat.jms(currentLocale).format(this);

  /// 使用 DateFormat.m 的国际化格式格式化日期
  /// >>> 30
  String get m => DateFormat.m(currentLocale).format(this);

  /// 使用 DateFormat.ms 的国际化格式格式化日期
  /// >>> 30:45
  String get ms => DateFormat.ms(currentLocale).format(this);

  /// 使用 DateFormat.s 的国际化格式格式化日期
  /// >>> 45
  String get s => DateFormat.s(currentLocale).format(this);

  /// 使用 DateFormat组合(yMMMMd + jms) 的国际化格式格式化日期
  /// >>> Thursday, May 1, 2025 12:30:45 PM
  /// >>> 2025年5月1日星期四 12:30:45 PM
  String get yMMMMEEEEd_jms => DateFormat.yMMMMEEEEd(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(yMMMMd + jm) 的国际化格式格式化日期
  /// >>> May 1, 2025 12:30 PM
  /// >>> 2025年5月1日 12:30
  String get yMMMMd_jm => DateFormat.yMMMMd(currentLocale).add_jm().format(this);

  /// 使用 DateFormat组合(yMMMMd + jms) 的国际化格式格式化日期
  /// >>> May 1, 2025 12:30:45 PM
  /// >>> 2025年5月1日 12:30:45
  String get yMMMMd_jms => DateFormat.yMMMMd(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(MMMd + jm) 的国际化格式格式化日期
  /// >>> May 1 12:30 PM
  /// >>> 5月1日 12:30
  String get MMMMd_jm => DateFormat.MMMMd(currentLocale).add_jm().format(this);

  /// 使用 DateFormat组合(MMMd + jms) 的国际化格式格式化日期
  /// >>> May 1 12:30:45 PM
  /// >>> 5月1日 12:30:45
  String get MMMMd_jms => DateFormat.MMMMd(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(yMEd + jms) 的国际化格式格式化日期
  /// >>> Thu, 5/1/2025 12:30:45 PM
  /// >>> 2025/5/1周四 12:30:45
  String get yMEd_jms => DateFormat.yMEd(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(yMd + jm) 的国际化格式格式化日期
  /// >>> 5/1/2025 12:30 PM
  /// >>> 2025/5/1 12:30
  String get yMd_jm => DateFormat.yMd(currentLocale).add_jm().format(this);

  /// 使用 DateFormat组合(yMd + jms) 的国际化格式格式化日期
  /// >>> 5/1/2025 12:30:45 PM
  /// >>> 2025/5/1 12:30:45
  String get yMd_jms => DateFormat.yMd(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(Md + jms) 的国际化格式格式化日期
  /// >>> 5/1 12:30 PM
  /// >>> 5/1 12:30
  String get Md_jm => DateFormat.Md(currentLocale).add_jm().format(this);

  /// 使用 DateFormat组合(Md + jms) 的国际化格式格式化日期
  /// >>> 5/1 12:30:45 PM
  /// >>> 5/1 12:30:45
  String get Md_jms => DateFormat.Md(currentLocale).add_jms().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> Thursday, May 1, 2025 12:30:45
  /// >>> 2025年5月1日星期四 12:30:45
  String get yMMMMEEEEd_Hms => DateFormat.yMMMMEEEEd(currentLocale).add_Hms().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> May 1, 2025 12:30
  /// >>> 2025年5月1日 12:30
  String get yMMMMd_Hm => DateFormat.yMMMMd(currentLocale).add_Hm().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> May 1, 2025 12:30:45
  /// >>> 2025年5月1日 12:30:45
  String get yMMMMd_Hms => DateFormat.yMMMMd(currentLocale).add_Hms().format(this);

  /// 使用 DateFormat组合(Md + Hm) 的国际化格式格式化日期
  /// >>> May 1 12:30
  /// >>> 5月1日 12:30
  String get MMMMd_Hm => DateFormat.MMMMd(currentLocale).add_Hm().format(this);

  /// 使用 DateFormat组合(Md + Hms) 的国际化格式格式化日期
  /// >>> May 1 12:30:45
  /// >>> 5月1日 12:30:45
  String get MMMMd_Hms => DateFormat.MMMMd(currentLocale).add_Hms().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> Thu, 5/1/2025 12:30:45
  /// >>> 2025/5/1周四 12:30:45
  String get yMEd_Hms => DateFormat.yMEd(currentLocale).add_Hms().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> 5/1/2025 12:30
  /// >>> 2025/5/1 12:30
  String get yMd_Hm => DateFormat.yMd(currentLocale).add_Hm().format(this);

  /// 使用 DateFormat组合(yMd + Hms) 的国际化格式格式化日期
  /// >>> 5/1/2025 12:30:45
  /// >>> 2025/5/1 12:30:45
  String get yMd_Hms => DateFormat.yMd(currentLocale).add_Hms().format(this);

  /// 使用 DateFormat组合(Md + Hm) 的国际化格式格式化日期
  /// >>> 5/1 12:30
  /// >>> 5月1日 12:30
  String get Md_Hm => DateFormat.Md(currentLocale).add_Hm().format(this);

  /// 使用 DateFormat组合(Md + Hms) 的国际化格式格式化日期
  /// >>> 5/1 12:30:45
  /// >>> 5月1日 12:30:45
  String get Md_Hms => DateFormat.Md(currentLocale).add_Hms().format(this);

  /// 组合DateFormat的通用方法
  /// [pattern] 要使用的模式
  /// [inputPattern] 要组合的模式
  /// [separator] 分隔符，默认为空字符串
  /// 例如: combineFormat('yQQQ', 'MMMd')
  /// >>> Q2 2025 May 1
  /// >>> 2025年第2季度 5月1日
  String combineFormat(
    String pattern,
    String? inputPattern, {
    String? locale,
    String separator = ' ',
  }) {
    final dateFormat = DateFormat(pattern, locale ?? currentLocale);
    if (inputPattern == null) return dateFormat.format(this);
    return dateFormat.addPattern(inputPattern, separator).format(this);
  }

  /// 使用指定模式的国际化格式格式化日期
  /// 'yyyy-MM-dd' >>> 2025-05-01, 2025年5月1日
  /// 'yyyy-MM-dd HH:mm:ss' >>> 2025-05-01 12:30:45, 2025年5月1日 12:30:45
  String format(String pattern, [String? locale]) {
    return DateFormat(pattern, locale ?? currentLocale).format(this);
  }
}

/// 使用-分隔符的日期格式化
const yyyyMMdd = 'yyyy-MM-dd';
const yyyyMM = 'yyyy-MM';
const MMdd = 'MM-dd';
const MMddHHmm = 'MM-dd HH:mm';
const MMddHHmmss = 'MM-dd HH:mm:ss';
const yyyyMMDDHHmmss = 'yyyy-MM-dd HH:mm:ss';
const yyyyMMDDHHmmssSSS = 'yyyy-MM-dd HH:mm:ss.SSS';

const HHmm = 'HH:mm';
const HHmmss = 'HH:mm:ss';
const HHmmssSSS = 'HH:mm:ss.SSS';
const mmssSSS = 'mm:ss.SSS';
