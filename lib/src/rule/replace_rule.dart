/// 词义扩展 - 对称呼词义进行扩展
class ReplaceRule {
  final RegExp exp;
  final List<String> arr;
  const ReplaceRule(this.exp, this.arr);
}

final List<ReplaceRule> replaceRules = [
  ReplaceRule(RegExp(r'^从表'), [
    '从父姑表',
    '从父舅表',
    '从父姨表',
    '从母姑表',
    '从母舅表',
    '从母叔表',
  ]),
  ReplaceRule(RegExp(r'^表表'), [
    '姑表叔表',
    '姑表姑表',
    '姑表舅表',
    '姑表姨表',
    '舅表叔表',
    '舅表姑表',
    '舅表舅表',
    '舅表姨表',
  ]),
  ReplaceRule(RegExp(r'^([夫妻内外]?)表'), [r'$1姑表', r'$1舅表']),
  ReplaceRule(RegExp(r'^([姑舅])表(?=[^伯叔])'), [r'$1表伯', r'$1表叔']),
  ReplaceRule(RegExp(r'^姻'), ['姑姻', '姨姻', '姊妹姻', '女姻']),
  ReplaceRule(RegExp(r'^眷'), ['叔眷', '舅眷', '兄弟眷', '男眷']),
  ReplaceRule(RegExp(r'^亲家'), ['姊妹姻', '兄弟眷']),
  ReplaceRule(
    RegExp(r'^([堂表姨]?)([曾高天烈太远鼻]?)(祖?)([伯叔姑舅姨])'),
    [r'$1$4$2$3'],
  ),
  ReplaceRule(RegExp(r'^([曾高天烈太远鼻]?)祖?王姑'), [r'姑$1祖母']),
  ReplaceRule(RegExp(r'^([曾玄元来晜仍云耳])([侄甥])'), [r'$2$1']),
  ReplaceRule(RegExp(r'^外表([伯叔姑舅姨])'), [r'姑表$1外', r'舅表$1外']),
  ReplaceRule(RegExp(r'([堂表姨]?)外甥'), [r'$1甥']),
  ReplaceRule(RegExp(r'^([舅叔])([曾玄外]*)孙'), [r'$1侄$2孙']),
  ReplaceRule(RegExp(r'^([姨姑])([曾玄外]*)孙'), [r'$1甥$2孙']),
  ReplaceRule(RegExp(r'([孙甥侄])$'), [r'$1男', r'$1女']),
  ReplaceRule(
    RegExp(r'([姑舅姨叔])([孙外]*)([男女])$'),
    [r'$1表侄$2$3', r'$1表甥$2$3'],
  ),
  ReplaceRule(RegExp(r'(.+)父母$'), [r'$1父', r'$1母']),
  ReplaceRule(RegExp(r'(.+)公婆$'), [r'$1公', r'$1婆']),
  ReplaceRule(RegExp(r'祖$'), ['祖父']),
  ReplaceRule(RegExp(r'(新妇|媳)$'), ['媳妇']),
  ReplaceRule(RegExp(r'嫂$'), ['兄妇']),
  ReplaceRule(RegExp(r'女儿$'), ['女']),
];
