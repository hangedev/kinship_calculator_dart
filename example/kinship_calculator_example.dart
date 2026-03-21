import 'package:kinship_calculator/kinship_calculator.dart';

void main() {
  final demo1 = relationship(text: '爸爸的哥哥的儿子');
  final demo2 = relationship(text: '爸爸的弟弟', reverse: true);
  final demo3 = relationship(text: '妈妈的妈妈', reverse: true, sex: 1);
  final demo4 = relationship(text: '曾祖母', type: 'chain');

  print('$demo1\n$demo2\n$demo3\n$demo4\n');
}
