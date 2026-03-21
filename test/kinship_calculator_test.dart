import 'package:kinship_calculator/kinship_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('call tests', () {
    test('basic relationship calculations', () {
      expect(
        relationship(text: '爸爸的哥哥的弟弟的儿子'),
        equals(['堂哥', '堂弟', '哥哥', '弟弟', '自己']),
      );
      expect(
        relationship(text: '爸爸的妹妹的女儿的老公'),
        equals(['姑表姐夫', '姑表妹夫']),
      );
      expect(
        relationship(text: '表姐的哥哥', sex: 1),
        equals(['姑表哥', '舅表哥']),
      );
      expect(
        relationship(text: '表姐的妹妹', sex: 1),
        equals(['姑表姐', '姑表妹', '舅表姐', '舅表妹']),
      );
      expect(
        relationship(text: '弟弟的表哥', sex: 1),
        equals(['姑表哥', '姑表弟', '舅表哥', '舅表弟']),
      );
      expect(
        relationship(text: '姐姐的老公的姐姐的老公'),
        equals(['姊妹姻姊妹壻']),
      );
      expect(
        relationship(text: '哥哥的弟弟的爸爸的儿子', sex: 1),
        equals(['哥哥', '弟弟', '自己']),
      );
      expect(relationship(text: '爱人', sex: 1), equals(['老婆']));
      expect(relationship(text: '爱人的爱人', sex: 1), equals(['自己']));
      expect(relationship(text: '老婆的爱人', sex: 1), equals(['自己']));
      expect(relationship(text: '老婆的老公', sex: 1), equals(['自己']));
      expect(
        relationship(text: '老婆的外孙的姥爷', sex: 1),
        equals(['自己']),
      );
      expect(
        relationship(text: '老公的老婆的儿子的爸爸', sex: 0),
        equals(['老公']),
      );
      expect(
        relationship(text: '堂兄弟的孩子', sex: 1),
        equals(['堂侄', '堂侄女']),
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
  });

  group('target tests', () {
    test('relationship with target', () {
      expect(
        relationship(text: '我', target: '爸爸'),
        equals(['儿子', '女儿']),
      );
      expect(
        relationship(text: '老公的父母', target: '孩子'),
        equals(['爷爷', '奶奶']),
      );
      expect(
        relationship(text: '爱人', target: '娘家侄子'),
        equals(['姑丈']),
      );
    });
  });

  group('reverse tests', () {
    test('reverse relationship', () {
      expect(
        relationship(text: '爸爸的舅舅', sex: 0, reverse: true),
        equals(['甥孙女']),
      );
      expect(
        relationship(
            text: '岳母', target: '女儿', reverse: true),
        equals(['外孙女']),
      );
      expect(
        relationship(
            text: '姑妈', target: '舅妈', reverse: true),
        equals(['兄弟眷兄弟妇']),
      );
      expect(
        relationship(
            text: '舅妈', target: '女儿', reverse: true),
        equals(['姑甥孙女', '姑甥外孙女']),
      );
      expect(
        relationship(
            text: '外婆', target: '女婿', reverse: true),
        equals(['外曾孙女婿', '外曾外孙女婿']),
      );
    });
  });

  group('filter tests', () {
    test('filter relationship', () {
      expect(
        relationship(text: '内侄'),
        equals(['舅侄', '舅侄女']),
      );
    });
  });

  group('chain type tests', () {
    test('chain type calculations', () {
      expect(
        relationship(text: '舅爷爷', type: 'chain'),
        equals(['爸爸的妈妈的兄弟']),
      );
      expect(
        relationship(text: '妻儿', type: 'chain'),
        equals(['老婆', '儿子', '女儿']),
      );
      expect(
        relationship(text: '父母', target: '老公', type: 'chain'),
        equals(['老婆的爸爸', '老婆的妈妈']),
      );
    });
  });

  group('pair type tests', () {
    test('pair type calculations', () {
      expect(
        relationship(text: '舅妈', target: '哥哥', type: 'pair'),
        equals(['舅甥']),
      );
      expect(
        relationship(text: '舅妈', target: '外婆', type: 'pair'),
        equals(['婆媳']),
      );
      expect(
        relationship(text: '舅妈', target: '二舅', type: 'pair'),
        equals(['伯媳', '叔嫂', '夫妻']),
      );
      expect(
        relationship(text: '堂哥', target: '叔叔', type: 'pair'),
        equals(['伯侄', '叔侄', '父子']),
      );
    });
  });

  group('age tests', () {
    test('age/ranking calculations', () {
      expect(relationship(text: '妈妈的二哥'), equals(['二舅']));
      expect(relationship(text: '爸爸的二哥'), equals(['二伯']));
      expect(
        relationship(text: '二舅妈', target: '三舅'),
        equals(['二嫂']),
      );
      expect(relationship(text: '爸爸的二爸'), equals(['二爷爷']));
      expect(
        relationship(text: '姑姑', target: '叔叔', optimal: true),
        equals(['姐姐', '妹妹']),
      );
      expect(
        relationship(text: '大舅', target: '二舅的儿子'),
        equals(['伯父']),
      );
      expect(
        relationship(text: '二舅妈', target: '二舅', type: 'pair'),
        equals(['夫妻']),
      );
      expect(
        relationship(text: '二舅妈', target: '大舅', type: 'pair'),
        equals(['伯媳']),
      );
    });
  });

  group('expression tests', () {
    test('natural language expression parsing', () {
      expect(
        relationshipFromExpression('外婆和奶奶之间是什么关系？'),
        equals(['儿女亲家']),
      );
      expect(
        relationshipFromExpression('妈妈应该如何称呼姑姑'),
        equals(['姑子']),
      );
      expect(
        relationshipFromExpression('姑奶奶是什么关系'),
        equals(['爸爸的爸爸的姐妹']),
      );
      expect(
        relationshipFromExpression('姑奶奶和爸爸是什么关系'),
        equals(['姑侄']),
      );
      expect(
        relationshipFromExpression('我应该叫外婆的哥哥什么？'),
        equals(['舅外公']),
      );
      expect(
        relationshipFromExpression('七舅姥爷应该叫我什么？'),
        equals(['甥外孙', '甥外孙女']),
      );
      expect(
        relationshipFromExpression('舅公是什么关系？'),
        equals(['爸爸的妈妈的兄弟', '妈妈的妈妈的兄弟', '老公的妈妈的兄弟']),
      );
      expect(
        relationshipFromExpression('舅妈如何称呼外婆？'),
        equals(['婆婆']),
      );
      expect(
        relationshipFromExpression('外婆和奶奶之间是什么关系？'),
        equals(['儿女亲家']),
      );
    });
  });

  group('basic tests', () {
    test('default calculation', () {
      expect(
        relationship(text: '爸爸的妈妈的哥哥'),
        equals(['大舅爷']),
      );
    });

    test('gender specification', () {
      expect(
        relationship(text: '爸爸的妈妈的哥哥', reverse: true, sex: 1),
        equals(['甥孙']),
      );
      expect(
        relationship(text: '爸爸的妈妈的哥哥', reverse: true, sex: 0),
        equals(['甥孙女']),
      );
    });

    test('chain type', () {
      expect(
        relationship(text: '曾祖母', type: 'chain'),
        equals(['爸爸的爸爸的妈妈']),
      );
    });

    test('reverse calculation', () {
      expect(
        relationship(text: '爸爸的爸爸'),
        equals(['爷爷']),
      );
      expect(
        relationship(text: '爸爸的爸爸', reverse: true, sex: 1),
        equals(['孙子']),
      );
    });
  });
}
