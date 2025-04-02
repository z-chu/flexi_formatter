# FlexiFormatter

[![Build Status](https://github.com/FlexiKline/flexi_formatter/actions/workflows/publish.yml/badge.svg)](https://github.com/FlexiKline/flexi_formatter/actions/workflows/publish.yml)


A flexible and customizable Dart/Flutter library for formatting numbers, dates, and other data types.

For instance :

```dart
/// 987654321.123456789 => '987654321.12345'
print(formatNumber(987654321.123456789.d, precision: 5, roundMode: RoundMode.floor));

/// 1234567890.12345 => '$1,234,567,890.12'
print(formatPrice(1234567890.12345.d, precision: 2, prefix: '\$'));

/// 9876543210.1 => '9.88B'
print(formatAmount(9876543210.1.d));

/// 9876543210.1 => '9.87B'
print(formatAmount(9876543210.1.d, roundMode: RoundMode.floor));

/// 9876543210.1 => '98.77亿'
print(formatAmount(
  9876543210.1.d,
  compactConverter: FormatDecimal.simplifiedChineseCompactConverter,
));

/// 1234567890.000000789 => '￥+1_2345_6789.0₆78元'
print(formatNumber(
  '123456789.000000789'.d,
  precision: 8,
  roundMode: RoundMode.floor,
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
    roundMode: RoundMode.floor,
    cutInvalidZero: true,
    enableGrouping: true,
    shrinkZeroMode: ShrinkZeroMode.subscript,
    showSign: true,
    prefix: '￥',
    suffix: '元',
  ));
} finally {
  FlexiFormatter.restoreGlobalDefaultConfig();
}
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
