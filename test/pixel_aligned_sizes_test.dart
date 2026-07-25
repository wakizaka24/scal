import 'package:flutter_test/flutter_test.dart';
import 'package:scal/f003_calendar_page.dart';

void main() {
  test('returns no widths while calendar columns are not initialized', () {
    expect(createPixelAlignedSizes(393, 0, 3), isEmpty);
  });

  for (final (logicalWidth, columnCount, devicePixelRatio) in [
    (393.0, 7, 3.0),
    (375.0, 7, 2.0),
    (346.0, 6, 3.0),
  ]) {
    test('aligns $columnCount columns in ${logicalWidth}pt at '
        '${devicePixelRatio}x', () {
      final widths = createPixelAlignedSizes(
          logicalWidth, columnCount, devicePixelRatio);

      expect(widths, hasLength(columnCount));
      expect(
        widths.fold<double>(0, (total, width) => total + width),
        closeTo(logicalWidth, 0.000001),
      );

      var logicalPosition = 0.0;
      for (final width in widths) {
        logicalPosition += width;
        final physicalPosition = logicalPosition * devicePixelRatio;
        expect(physicalPosition, closeTo(physicalPosition.round(), 0.000001));
      }
    });
  }
}
