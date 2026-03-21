import 'package:kinship_calculator/kinship_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('KinshipCalculator calculation test', () {
    test('Default calculation test', () {
      final result = relationship(text: '爸爸的妈妈的哥哥');
      expect(result, equals(['大舅爷']));
    });

    test('Gender specification tests', () {
      final maleResult = relationship(
        text: '爸爸的妈妈的哥哥',
        reverse: true,
        sex: 1,
      );
      expect(maleResult, equals(['甥孙']));

      final femaleResult = relationship(
        text: '爸爸的妈妈的哥哥',
        reverse: true,
        sex: 0,
      );
      expect(femaleResult, equals(['甥孙女']));
    });

    test('Chain type calculation test', () {
      final result = relationship(
        text: '曾祖母',
        type: 'chain',
      );
      expect(result, equals(['爸爸的爸爸的妈妈']));
    });

    test('Reverse calculation tests', () {
      final normalResult = relationship(
        text: '爸爸的爸爸',
        reverse: false,
      );
      expect(normalResult, equals(['爷爷']));

      final reverseResult = relationship(
        text: '爸爸的爸爸',
        reverse: true,
        sex: 1,
      );
      expect(reverseResult, equals(['孙子']));
    });

    test('JS test suite - call tests', () {
      expect(
        relationship(text: '爸爸的哥哥的弟弟的儿子'),
        equals(['堂哥', '堂弟', '哥哥', '弟弟', '自己']),
      );
      expect(
        relationship(text: '爸爸的妹妹的女儿的老公'),
        equals(['姑表姐夫', '姑表妹夫']),
      );
      expect(
        relationship(text: '哥哥的弟弟的爸爸的儿子', sex: 1),
        equals(['哥哥', '弟弟', '自己']),
      );
      expect(
        relationship(text: '老公的老婆的儿子的爸爸', sex: 0),
        equals(['老公']),
      );
      expect(
        relationship(text: '儿子的爸爸的妈妈', sex: 1),
        equals(['妈妈']),
      );
      expect(
        relationship(text: '岳母的配偶的孩子的爸爸'),
        equals(['岳父']),
      );
      expect(
        relationship(text: '爸爸的妈妈的姐姐的儿子'),
        equals(['姨伯父', '姨叔父']),
      );
    });

    test('Target tests', () {
      expect(
        relationship(text: '我', target: '爸爸'),
        equals(['儿子', '女儿']),
      );
      expect(
        relationship(text: '爸爸', target: '妈妈'),
        equals(['老公']),
      );
      expect(
        relationship(text: '妈妈', target: '爸爸'),
        equals(['老婆']),
      );
    });

    test('Reverse tests', () {
      expect(
        relationship(text: '爸爸', reverse: true),
        equals(['儿子', '女儿']),
      );
      expect(
        relationship(text: '爸爸', reverse: true, sex: 1),
        equals(['儿子']),
      );
      expect(
        relationship(text: '爸爸', reverse: true, sex: 0),
        equals(['女儿']),
      );
      expect(
        relationship(text: '爸爸的舅舅', sex: 0, reverse: true),
        equals(['甥孙女']),
      );
    });

    test('Chain type test', () {
      expect(
        relationship(text: '姑奶奶', type: 'chain'),
        equals(['爸爸的爸爸的姐妹']),
      );
    });

    test('Pair type test', () {
      expect(
        relationship(text: '姑奶奶', target: '爸爸', type: 'pair'),
        equals(['姑侄']),
      );
    });

    test('Expression tests', () {
      expect(
        relationshipFromExpression('我应该叫外婆的哥哥什么？'),
        equals(['舅外公']),
      );
      expect(
        relationshipFromExpression('七舅姥爷应该叫我什么？'),
        equals(['甥外孙', '甥外孙女']),
      );
    });
  });
}
