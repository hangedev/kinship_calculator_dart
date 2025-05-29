import 'package:kinship_calculator/kinship_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('KinshipCalculator calculation test', () {
    test('Default calculation test', () {
      final result = KinshipCalculator.calculate(KinshipOption(
        text: '爸爸的妈妈的哥哥',
      ));
      expect(result, equals(['舅公']));
    });

    test('Gender specification tests', () {
      final maleResult = KinshipCalculator.calculate(KinshipOption(
        text: '爸爸的妈妈的哥哥',
        reverse: true,
        sex: 1,
      ));
      expect(maleResult, equals(['外甥孙']));

      final femaleResult = KinshipCalculator.calculate(KinshipOption(
        text: '爸爸的妈妈的哥哥',
        reverse: true,
        sex: 0,
      ));
      expect(femaleResult, equals(['外甥孙女']));
    });

    test('Chain type calculation test', () {
      final result = KinshipCalculator.calculate(KinshipOption(
        text: '曾祖母',
        type: 'chain',
      ));
      expect(result, equals(['爸爸的爸爸的妈妈']));
    });

    test('Reverse calculation tests', () {
      final normalResult = KinshipCalculator.calculate(KinshipOption(
        text: '爸爸的爸爸',
        reverse: false,
      ));
      expect(normalResult, equals(['爷爷']));

      final reverseResult = KinshipCalculator.calculate(KinshipOption(
        text: '爸爸的爸爸',
        reverse: true,
      ));
      expect(reverseResult, equals(['孙子']));
    });
  });
}
