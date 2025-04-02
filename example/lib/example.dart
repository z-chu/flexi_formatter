import 'package:flexi_formatter/flexi_formatter.dart';

void main() {
  /// 987654321.123456789 => '987654321.12345'
  print(formatNumber(987654321.123456789.d, precision: 5, roundMode: RoundMode.floor));

  /// 1.00000123000 => '1.0{5}123'
  print(formatNumber(
    1.00000123000.d,
    precision: 10,
    cutInvalidZero: true,
    shrinkZeroMode: ShrinkZeroMode.compact,
  ));

  /// 0.1 => '10.00%'
  print(formatPercentage(0.1.d));

  /// 1234567890.12345 => '$1,234,567,890.12'
  print(formatPrice(1234567890.12345.d, precision: 2, prefix: '\$'));

  /// 9876543210.1 => '9.88B'
  print(formatAmount(9876543210.1.d));

  /// 9876543210.1 => '9.87B'
  print(formatAmount(9876543210.1.d, roundMode: RoundMode.floor));

  /// 9876543210.1 => '98.77亿'
  print(formatAmount(
    9876543210.1.d,
    compactConverter: FlexiFormatter.simplifiedChineseCompactConverter,
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

  print('￥+123456.0{6}789元'.ltr);
  print('￥${'+123456.0{6}789'.ltr}元'.rtl);
}
