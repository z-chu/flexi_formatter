import 'package:flexi_formatter/flexi_formatter.dart';

void main() {
  /// 987654321.123456789 => '987654321.12345'
  print(formatNumber(987654321.123456789.d, precision: 5, mode: RoundMode.floor));

  /// 1.00000123000 => '1.0{5}123'
  print(formatNumber(
    1.00000123000.d,
    precision: 10,
    cutInvalidZero: true,
    useZeroPadding: true,
  ));

  /// 0.1 => '10.00%'
  print(formatPercentage(0.1.d));

  /// 1234567890.12345 => '$1,234,567,890.12'
  print(formatPrice(1234567890.12345.d, precision: 2, prefix: '\$'));

  /// 9876543210.1 => '9.88B'
  print(formatAmount(9876543210.1.d));

  /// 9876543210.1 => '98.77亿'
  print(formatAmount(
    9876543210.1.d,
    compactConverter: FormatDecimal.simplifiedChineseCompactConverter,
  ));

  /// 123456.000000789 => '$+123 456.0{6}789USDT'
  FormatDecimal.thousandSeparator = ' ';
  print(formatNumber(
    123456.000000789.d,
    precision: 100,
    cutInvalidZero: true,
    showThousands: true,
    useZeroPadding: true,
    prefix: '\$',
    suffix: 'USDT',
    showSign: true,
  ));
}
