import 'package:flexi_formatter/flexi_formatter.dart';
import 'package:test/test.dart' show test, expect;

void main() {
  test('test zeroPadding', () {
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
        shrinkZeroMode: ShrinkZeroMode.compact,
      )}');
    }
  });

  test('test formatPercentage', () {
    var result = formatPercentage(0.1.d, cutInvalidZero: false);
    expect(result, "10.00%");
    result = formatPercentage(0.1.d, cutInvalidZero: true);
    expect(result, "10%");

    result = formatPercentage(0.98765.d, cutInvalidZero: false);
    expect(result, "98.76%");
    result = formatPercentage(0.98765.d, cutInvalidZero: true);
    expect(result, "98.76%");
  });

  test('test formatPrice', () {
    var result = formatPrice(0.1.d, precision: 2, cutInvalidZero: false, prefix: '\$');
    expect(result, "\$0.10");
    result = formatPrice(0.1.d, precision: 2, cutInvalidZero: true, prefix: '\$');
    expect(result, "\$0.1");

    result = formatPrice(123456.789.d, precision: 2, prefix: '\$');
    expect(result, "\$123,456.78");

    result = formatPrice(123456.000000789.d, precision: 9, prefix: '\$');
    expect(result, "\$123,456.0{6}789");
  });

  test('test formatAmount', () {
    var result = formatAmount(12345.1.d, precision: 2);
    expect(result, "12.35K");

    result = formatAmount(123456789.d, precision: 3);
    expect(result, "123.457M");

    result = formatAmount(
      123456789.d,
      precision: 3,
      compactConverter: FormatDecimal.simplifiedChineseCompactConverter,
    );
    expect(result, "1.235亿");
  });

  test('test formatNumber', () {
    FormatDecimal.thousandSeparator = ' ';
    var result = formatNumber(
      123456.000000789.d,
      precision: 100,
      cutInvalidZero: true,
      showThousands: true,
      shrinkZeroMode: ShrinkZeroMode.subscript,
      prefix: '\$',
      suffix: 'USDT',
      showSign: true,
    );
    print(result);
    expect(result, "\$+123 456.0₆789USDT");
  });
}
