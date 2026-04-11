import 'package:flutter_test/flutter_test.dart';
import 'package:purrfect_spots/services/xsb_parser.dart';

void main() {
  group('XsbParser', () {
    test('parses a simple XSB level', () {
      const xsb = '''
; Level 1
####
# .#
#  ###
#*@  #
#  \$ #
#  ###
####
''';

      final levels = XsbParser.parseMultipleLevels(xsb);

      expect(levels.length, 1);
      final level = levels[0];
      expect(level.playerStart.row, 3);
      expect(level.playerStart.col, 2);
      expect(level.catStarts.length, 2); // $ and * (box on goal)
      expect(level.targetPositions.length, 2); // . and * (goal and box on goal)
    });

    test('parses multiple levels separated by blank lines', () {
      const xsb = '''
; Level 1
######
#    #
# #@ #
# \$* #
# .* #
#    #
######

; Level 2
  ####
###  ####
#     \$ #
# #  #\$ #
# . .#@ #
#########
''';

      final levels = XsbParser.parseMultipleLevels(xsb);
      expect(levels.length, 2);
      expect(levels[0].floor, 1);
      expect(levels[1].floor, 2);
    });

    test('handles player on goal (+)', () {
      const xsb = '''
#####
# \$ #
#.+\$#
#   #
#####
''';

      final levels = XsbParser.parseMultipleLevels(xsb);
      expect(levels.length, 1);
      final level = levels[0];
      // + means player on goal, so targets include that position
      expect(level.targetPositions.length, 2); // one . and the +
      expect(level.catStarts.length, 2); // two $
    });

    test('uses comment as level name', () {
      const xsb = '''
; The First Puzzle
####
#@ #
#\$.#
####
''';

      final levels = XsbParser.parseMultipleLevels(xsb);
      expect(levels.length, 1);
      expect(levels[0].name, 'The First Puzzle');
    });
  });
}
