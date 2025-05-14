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

import 'dart:math' as math;

import 'package:intl/date_symbol_data_local.dart' as date_intl;
import 'package:intl/intl.dart';

import '../formatter_config.dart';

part 'constants.dart';
part 'extension.dart';
part 'format_extension.dart';

/// A utility class for DateTime operations.
class DateTimeUtils {
  DateTimeUtils._();

  /// Adds the specified number of months to the given [dateTime].
  ///
  /// The [months] parameter specifies the number of months to add.
  /// If the resulting month has fewer days than the original day,
  /// the day will be adjusted to the last day of the resulting month.
  ///
  /// Returns a new [DateTime] object with the added months.
  static DateTime addMonths(DateTime dateTime, int months) {
    final modMonths = months % 12;
    var newYear = dateTime.year + ((months - modMonths) ~/ 12);
    var newMonth = dateTime.month + modMonths;
    if (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    final newDay = math.min(dateTime.day, DateTime(newYear, newMonth).daysInMonth);
    return dateTime.copyWith(
      year: newYear,
      month: newMonth,
      day: newDay,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
    );
  }

  /// Gets the start day of the week based on the locale.
  ///
  /// Returns a [StartOfWeek] enum value representing the start day of the week.
  /// Throws an [Exception] if the locale is not supported.
  static StartOfWeek getStartOfWeek() {
    final locale = FlexiFormatter.currentLocale;
    final supportedLocale = date_intl.dateTimeSymbolMap()[locale];

    if (supportedLocale == null) {
      throw Exception("The specified locale '$locale' is not supported.");
    }

    return switch (supportedLocale.FIRSTDAYOFWEEK) {
      0 => StartOfWeek.monday,
      5 => StartOfWeek.saturday,
      6 => StartOfWeek.sunday,
      _ => throw Exception(
          'Start of week with index ${supportedLocale.FIRSTDAYOFWEEK} not supported',
        ),
    };
  }

  /// Calculates the difference in months between two [DateTime] objects.
  ///
  /// The [first] and [second] parameters specify the two
  /// dates to compare.
  ///
  /// Returns the difference in months as a [num].
  static num monthDiff(DateTime first, DateTime second) {
    if (first.day < second.day) {
      return -DateTimeUtils.monthDiff(second, first);
    }

    final monthDiff = ((second.year - first.year) * 12) + (second.month - first.month);

    final thirdDateTime = addMonths(first, monthDiff);
    final thirdMicroseconds = thirdDateTime.microsecondsSinceEpoch;

    final diffMicroseconds = second.microsecondsSinceEpoch - thirdMicroseconds;

    double offset;
    if (diffMicroseconds < 0) {
      final fifthDateTime = addMonths(first, monthDiff - 1);
      offset = diffMicroseconds / (thirdMicroseconds - fifthDateTime.microsecondsSinceEpoch);
    } else {
      final fifthDateTime = addMonths(first, monthDiff + 1);
      offset = diffMicroseconds / (fifthDateTime.microsecondsSinceEpoch - thirdMicroseconds);
    }

    return -(monthDiff + offset);
  }
}
