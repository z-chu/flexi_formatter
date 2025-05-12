# FlexiFormatter

[![Build Status](https://github.com/FlexiKline/flexi_formatter/actions/workflows/publish.yml/badge.svg)](https://github.com/FlexiKline/flexi_formatter/actions/workflows/publish.yml)


A flexible and customizable Dart/Flutter library for formatting numbers, dates, and other data types.

For instance :

```dart
/// 987654321.123456789 => '987654321.12345'
print(formatNumber(987654321.123456789.d, precision: 5, roundMode: RoundMode.truncate));

/// 1.00000123000 => '1.0{5}123'
print(formatNumber(
  1.00000123000.d,
  precision: 10,
  cutInvalidZero: true,
  shrinkZeroMode: ShrinkZeroMode.curlyBraces,
));

/// 0.1 => '10.00%'
print(formatPercentage(0.1.d));

/// 1234567890.12345 => '$1,234,567,890.12'
print(formatPrice(1234567890.12345.d, precision: 2, prefix: '\$'));

/// 9876543210.1 => '9.88B'
print(formatAmount(9876543210.1.d));

/// 9876543210.1 => '9.87B'
print(formatAmount(9876543210.1.d, roundMode: RoundMode.truncate));

/// 9876543210.1 => '98.77亿'
print(formatAmount(
  9876543210.1.d,
  compactConverter: simplifiedChineseCompactConverter,
));

/// 1234567890.000000789 => '￥+1_2345_6789.0₆78元'
print(formatNumber(
  '123456789.000000789'.d,
  precision: 8,
  roundMode: RoundMode.truncate,
  cutInvalidZero: true,
  enableGrouping: true,
  groupSepartor: '_',
  groupCounts: 4,
  shrinkZeroMode: ShrinkZeroMode.subscript,
  showSign: true,
  prefix: '￥',
  suffix: '元',
));

/// 123456789.000000789 => '￥+1.2345.6789,0₆78元'
try {
  FlexiFormatter.setGlobalConfig(decimalSeparator: ',', groupSeparator: '.', groupCounts: 4);
  print(formatNumber(
    '123456789.000000789'.d,
    precision: 8,
    roundMode: RoundMode.truncate,
    cutInvalidZero: true,
    enableGrouping: true,
    shrinkZeroMode: ShrinkZeroMode.subscript,
    showSign: true,
    prefix: '￥',
    suffix: '元',
  ));
} finally {
  FlexiFormatter.restoreGlobalConfig();
}
```

```dart
initializeDateFormatting();
final now = DateTime.now();
printFormatDateTime(now, 'en-US');
printFormatDateTime(now, 'zh-CN');
printFormatDateTime(now, 'zh-TW');

void printFormatDateTime(DateTime dateTime, [String? locale]) {
  print('-----$locale------');
  FlexiFormatter.setCurrentLocale(locale);
  print('MMMEd \t: ${dateTime.MMMEd}');
  print('QQQQ \t: ${dateTime.QQQQ}');
  print('yMd \t: ${dateTime.yMd}');
  print('yMMMEd \t: ${dateTime.yMMMEd}');
  print('yMMMMEEEEd \t: ${dateTime.yMMMMEEEEd}');
  print('combine(yMMMMEEEEd + jms) \t: ${dateTime.yMMMMEEEEd_jms}');
  print('combine(yMEd + jms) \t: ${dateTime.yMEd_jms}');
  print(
    'combine(yQQQ + MMMd) \t: ${dateTime.combineFormat(DateFormat.YEAR_ABBR_QUARTER, DateFormat.ABBR_MONTH_DAY)}',
  );
  print('format(yMEd) \t: ${dateTime.format(DateFormat.YEAR_NUM_MONTH_WEEKDAY_DAY)}');
  print('format(yyyyMMDDHHmmssSSS) \t: ${dateTime.format(yyyyMMDDHHmmssSSS)}');
}

>>> output :
-----en-US------
MMMEd 	: Mon, May 12
QQQQ 	  : 2nd quarter
yMd 	  : 5/12/2025
yMMMEd 	: Mon, May 12, 2025
yMMMMEEEEd 	: Monday, May 12, 2025
combine(yMMMMEEEEd + jms) 	: Monday, May 12, 2025 4:48:18 PM
combine(yMEd + jms) 	: Mon, 5/12/2025 4:48:18 PM
combine(yQQQ + MMMd) 	: Q2 2025 May 12
format(yMEd) 	: Mon, 5/12/2025
format(yyyyMMDDHHmmssSSS) 	: 2025-05-12 16:48:18.026
-----zh-CN------
MMMEd 	: 5月12日周一
QQQQ 	  : 第二季度
yMd 	  : 2025/5/12
yMMMEd 	: 2025年5月12日周一
yMMMMEEEEd 	: 2025年5月12日星期一
combine(yMMMMEEEEd + jms) 	: 2025年5月12日星期一 16:48:18
combine(yMEd + jms) 	: 2025/5/12周一 16:48:18
combine(yQQQ + MMMd) 	: 2025年第2季度 5月12日
format(yMEd) 	: 2025/5/12周一
format(yyyyMMDDHHmmssSSS) 	: 2025-05-12 16:48:18.026
```

## Usage
To use this library in your code :
* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  flexi_formatter:
```

* add import in your `dart` code :

```dart
import 'package:flexi_formatter/flexi_formatter.dart';
```

* Start formatting using `formatNumber('987654321.0123456789'.d, precision: 5)`.


## License
Apache 2.0
