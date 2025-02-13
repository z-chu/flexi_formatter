# FlexiFormatter

[![Build Status](https://github.com/FlexiKline/flexi_formatter/actions/workflows/dart.yml/badge.svg)](https://github.com/FlexiKline/flexi_formatter/actions/workflows/dart.yml)


A flexible and customizable Dart/Flutter library for formatting numbers, dates, and other data types.

For instance :

```dart
/// 987654321.123456789 => '987654321.12345'
print(formatNumber(987654321.123456789.d, precision: 5, mode: RoundMode.floor));

/// 1234567890.12345 => '$1,234,567,890.12'
print(formatPrice(1234567890.12345.d, precision: 2, prefix: '\$'));

/// 9876543210.1 => '9.88B'
print(formatAmount(9876543210.1.d));
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

* Start formatting using `formatNumber(987654321.0123456789.d, precision: 5)`.


## License
Apache 2.0
