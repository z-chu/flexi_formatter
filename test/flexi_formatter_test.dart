import 'package:flexi_formatter/flexi_formatter.dart';
import 'package:test/test.dart' show test, expect;

void main() {
  test('test ShrinkZeroMode', () {
    const list = <String>[
      '100000',
      '1.123',
      '1.0123',
      '1.00123',
      '1.000123',
      '1.0000123',
      '1.00000123',
      '1.0000000',
    ];
    for (final str in list) {
      print('$str\t=>\t${formatNumber(
        str.d,
        precision: 10,
        cutInvalidZero: true,
        shrinkZeroMode: ShrinkZeroMode.curlyBraces,
      )}');
    }
  });

  test('test formatPercentage', () {
    print('=====formatPercentage=====');

    var result = formatPercentage(0.1.d, cutInvalidZero: false);
    print(result);
    expect(result, "10.00%");

    result = formatPercentage(0.1.d, cutInvalidZero: true);
    print(result);
    expect(result, "10%");

    result = formatPercentage(0.98765.d, cutInvalidZero: false);
    print(result);
    expect(result, "98.76%");

    result = formatPercentage(0.98765.d, cutInvalidZero: true);
    print(result);
    expect(result, "98.76%");
  });

  test('test formatPrice', () {
    print('=====formatPrice=====');

    var result = formatPrice(0.1.d, precision: 2, cutInvalidZero: false, prefix: '\$');
    print(result);
    expect(result, "\$0.10");

    result = formatPrice(0.1.d, precision: 2, cutInvalidZero: true, prefix: '\$');
    print(result);
    expect(result, "\$0.1");

    result = formatPrice(123456.789.d, precision: 2, prefix: '\$');
    print(result);
    expect(result, "\$123,456.78");

    result = formatPrice(
      123456.000000789.d,
      precision: 9,
      prefix: '\$',
      shrinkZeroMode: ShrinkZeroMode.curlyBraces,
    );
    print(result);
    expect(result, "\$123,456.0{6}789");
  });

  test('test formatAmount', () {
    print('=====formatAmount=====');

    var result = formatAmount(12345.1.d, precision: 2);
    print(result);
    expect(result, "12.35K");

    result = formatAmount(123456789.d, precision: 3);
    print(result);
    expect(result, "123.457M");

    result = formatAmount(
      123456789.d,
      precision: 3,
      compactConverter: FlexiFormatter.simplifiedChineseCompactConverter,
    );
    print(result);
    expect(result, "1.235亿");
  });

  test('test formatNumber', () {
    print('=====formatNumber=====');

    var result = formatNumber(
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
    );
    print(result);
    expect(result, "￥+1_2345_6789.0₆78元");
  });

  test('test global configuration', () {
    print('=====global configuration=====');

    /// 123456789.000000789 => '￥+1.2345.6789,0₆78元'
    try {
      FlexiFormatter.setGlobalConfig(decimalSeparator: ',', groupSeparator: '.', groupCounts: 4);
      var result = formatNumber(
        '123456789.000000789'.d,
        precision: 8,
        roundMode: RoundMode.truncate,
        cutInvalidZero: true,
        enableGrouping: true,
        shrinkZeroMode: ShrinkZeroMode.subscript,
        showSign: true,
        prefix: '￥',
        suffix: '元',
      );
      print(result);
      expect(result, "￥+1.2345.6789,0₆78元");
    } finally {
      FlexiFormatter.restoreGlobalConfig();
    }
  });

  test('test custom shrin zero converter', () {
    print('=====custom shrin zero converter=====');

    /// 123456789.000000789 => '￥+123,456,789.0<₆>78元'
    try {
      FlexiFormatter.setGlobalConfig(shrinkZeroConverter: (zeroCounts) {
        return '0<${zeroCounts.subscriptNumeral}>';
      });
      var result = formatNumber(
        '123456789.000000789'.d,
        precision: 8,
        roundMode: RoundMode.truncate,
        cutInvalidZero: true,
        enableGrouping: true,
        showSign: true,
        prefix: '￥',
        suffix: '元',
      );
      print(result);
      expect(result, "￥+123,456,789.0<₆>78元");
    } finally {
      FlexiFormatter.restoreGlobalConfig();
    }
  });
}
