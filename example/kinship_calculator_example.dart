import 'package:kinship_calculator/kinship_calculator.dart';

void main() {
  // 通过关系链计算称谓
  print(relationship(text: '爸爸的哥哥的儿子'));
  // => [堂哥, 堂弟]

  // 逆向查找
  print(relationship(text: '爸爸的弟弟', reverse: true));
  // => [侄子, 侄女]

  // 指定性别
  print(relationship(text: '妈妈的妈妈', reverse: true, sex: 1));
  // => [外孙]

  // 通过称谓计算关系链
  print(relationship(text: '曾祖母', type: 'chain'));
  // => [爸爸的爸爸的妈妈]

  // 相对对象
  print(relationship(text: '外婆', target: '舅妈', sex: 1));
  // => [婆婆]

  // 关系合称
  print(relationship(text: '外婆', target: '奶奶', type: 'pair'));
  // => [儿女亲家]

  // 年龄/排行
  print(relationship(text: '妈妈的二哥'));
  // => [二舅]

  // 最短关系
  print(relationship(text: '姑姑', target: '叔叔', optimal: true));
  // => [姐姐, 妹妹]

  // 自然语言表达
  print(relationshipFromExpression('我应该叫外婆的哥哥什么？'));
  // => [舅外公]

  print(relationshipFromExpression('外婆和奶奶之间是什么关系？'));
  // => [儿女亲家]
}
