/// 关系链缩写规则 - 将关系链缩减成最简表达
///
/// 关系数据语法说明：
/// 【关系符】 f:父; m:母; h:夫; w:妻; s:子; d:女; xb:兄弟; ob:兄; lb:弟; xs:姐妹; os:姐; ls:妹
/// 【修饰符】 1:男性; 0:女性; &o:年长; &l:年幼; &\d+:排序 #:隔断; [a|b]:并列
class FilterRule {
  final RegExp exp;
  final String str;
  const FilterRule(this.exp, this.str);
}

final List<FilterRule> filterRules = [
  /* 年龄 */
  // 有大有小，增加不确定性
  FilterRule(RegExp(r'^(.+)&o([^#]+)&l'), r'$1$2'),
  // 有大有小，增加不确定性
  FilterRule(RegExp(r'^(.+)&l([^#]+)&o'), r'$1$2'),
  // 有大有小，增加不确定性
  FilterRule(RegExp(r'^(.+)?,o([sb](&\d+)?)([^#]+)&l'), r'$1,x$2$4'),
  // 有大有小，增加不确定性
  FilterRule(RegExp(r'^(.+)?,l([sb](&\d+)?)([^#]+)&o'), r'$1,x$2$4'),

  /* 兄弟姐妹 */
  // 哥哥姐姐的哥哥姐姐还是自己的哥哥姐姐(年龄判断)
  FilterRule(RegExp(r'(,o[sb](&\d+)?)+(,o[sb])(&\d+)?'), r'$3$4'),
  // 弟弟妹妹的弟弟妹妹还是自己的弟弟妹妹(年龄判断)
  FilterRule(RegExp(r'(,l[sb](&\d+)?)+(,l[sb])(&\d+)?'), r'$3$4'),
  // 如果自己是男性,兄弟姐妹的兄弟就是自己的兄弟或自己
  FilterRule(
    RegExp(r'^(.*,[fh1])(,[olx][sb](&\d+)?)+,[olx]b(.*)$'),
    r'$1,xb$4#$1$4',
  ),
  // 如果自己是女性,兄弟姐妹的姐妹就是自己的姐妹或自己
  FilterRule(
    RegExp(r'^(.*,[mw0])(,[olx][sb](&\d+)?)+,[olx]s(.*)$'),
    r'$1,xs$4#$1$4',
  ),
  // 如果自己是男性,兄弟姐妹的姐妹就是自己的姐妹
  FilterRule(
    RegExp(r'(,[fh1])(,[olx][sb](&\d+)?)+,[olx]s'),
    r'$1,xs',
  ),
  // 如果自己是女性,兄弟姐妹的兄弟就是自己的兄弟
  FilterRule(
    RegExp(r'(,[mw0])(,[olx][sb](&\d+)?)+,[olx]b'),
    r'$1,xb',
  ),
  // 不知道性别，兄弟姐妹的兄弟是兄弟或自己
  FilterRule(
    RegExp(r'^,[olx][sb](&\d+)?,[olx]b(.+)?$'),
    r',xb$2#$2',
  ),
  // 不知道性别，兄弟姐妹的姐妹是姐妹或自己
  FilterRule(
    RegExp(r'^,[olx][sb](&\d+)?,[olx]s(.+)?$'),
    r',xs$2#$2',
  ),
  // 将复合称谓拆分
  FilterRule(RegExp(r'^,x([sb])$'), r',o$1#,l$1'),

  /* 父母 */
  // 母亲的丈夫是自己的父亲
  FilterRule(RegExp(r'm,h'), r'f'),
  // 父亲的妻子是自己的母亲
  FilterRule(RegExp(r'f,w'), r'm'),
  // 兄弟的父母就是自己的父母
  FilterRule(RegExp(r',[xol][sb](&\d+)?(,[mf])'), r'$2'),

  /* 父母的子女 */
  // 父母的女儿排序判断姐妹的排序
  FilterRule(RegExp(r',[mf],d(&\d+)'), r',xs$1'),
  // 父母的女儿年龄判断是姐姐还是妹妹
  FilterRule(RegExp(r',[mf],d&([ol])'), r',$1s'),
  // 父母的儿子排序判断兄弟的排序
  FilterRule(RegExp(r',[mf],s(&\d+)'), r',xb$1'),
  // 父母的儿子年龄判断是哥哥还是弟弟
  FilterRule(RegExp(r',[mf],s&([ol])'), r',$1b'),
  // 如果自己是男性,父母的儿子是兄弟或者自己
  FilterRule(
    RegExp(r'^(.*,[fh1]|[xol]b(&\d+)?),[mf],s(.*)$'),
    r'$1,xb$3#$1$3',
  ),
  // 如果自己是女性,父母的女儿是姐妹或者自己
  FilterRule(
    RegExp(r'^(.*,[mw0]|[xol]s(&\d+)?),[mf],d(.*)$'),
    r'$1,xs$3#$1$3',
  ),
  // 如果自己是女性,父母的儿子是自己的兄弟
  FilterRule(
    RegExp(r'(,[mw0]|[xol]s(&\d+)?),[mf],s'),
    r'$1,xb',
  ),
  // 如果自己是男性,父母的女儿是自己的姐妹
  FilterRule(
    RegExp(r'(,[fh1]|[xol]b(&\d+)?),[mf],d'),
    r'$1,xs',
  ),
  // 父母的儿子是兄弟或自己
  FilterRule(RegExp(r'^,[mf],s(.+)?$'), r',xb$1#,1$1'),
  // 父母的女儿是姐妹或者自己
  FilterRule(RegExp(r'^,[mf],d(.+)?$'), r',xs$1#,0$1'),

  /* 孩子 */
  // 孩子的兄弟是自己的儿子(排序判断)
  FilterRule(RegExp(r',[ds](&[ol\d]+)?,[olx]b(&\d+)'), r',s$2'),
  // 孩子的姐妹是自己的女儿(排序判断)
  FilterRule(RegExp(r',[ds](&[ol\d]+)?,[olx]s(&\d+)'), r',d$2'),
  // 孩子的兄弟是自己的儿子(年龄判断)
  FilterRule(RegExp(r',[ds]&o,ob'), r',s&o'),
  // 孩子的姐妹是自己的女儿(年龄判断)
  FilterRule(RegExp(r',[ds]&o,os'), r',d&o'),
  // 孩子的兄弟是自己的儿子(年龄判断)
  FilterRule(RegExp(r',[ds]&l,lb'), r',s&l'),
  // 孩子的姐妹是自己的女儿(年龄判断)
  FilterRule(RegExp(r',[ds]&l,ls'), r',d&l'),
  // 孩子的姐妹是自己的女儿
  FilterRule(RegExp(r',[ds](&[ol\d]+)?,[olx]s(&\d+)?'), r',d$2'),
  // 孩子的兄弟是自己的儿子
  FilterRule(RegExp(r',[ds](&[ol\d]+)?,[olx]b(&\d+)?'), r',s$2'),

  /* 夫妻 */
  // 自己是女性，女儿或儿子的妈妈是自己
  FilterRule(
    RegExp(r'(,[mwd0]|,[olx]s)(&[ol\d]+)?,[ds](&[ol\d]+)?,m'),
    r'$1',
  ),
  // 自己是女性，女儿或儿子的爸爸是自己的丈夫
  FilterRule(
    RegExp(r'(,[mwd0]|,[olx]s)(&[ol\d]+)?,[ds](&[ol\d]+)?,f'),
    r'$1,h',
  ),
  // 自己是男性，女儿或儿子的爸爸是自己
  FilterRule(
    RegExp(r'(,[fhs1]|,[olx]b)(&[ol\d]+)?,[ds](&[ol\d]+)?,f'),
    r'$1',
  ),
  // 自己是男性，女儿或儿子的妈妈是自己的妻子
  FilterRule(
    RegExp(r'(,[fhs1]|,[olx]b)(&[ol\d]+)?,[ds](&[ol\d]+)?,m'),
    r'$1,w',
  ),
  // 不知道性别，子女的妈妈是妻子或自己
  FilterRule(RegExp(r'^,[ds],m(.+)?$'), r',w$1#$1'),
  // 不知道性别，子女的爸爸是丈夫或自己
  FilterRule(RegExp(r'^,[ds],f(.+)?$'), r',h$1#$1'),
  // 夫妻的孩子就是自己的孩子
  FilterRule(RegExp(r',[wh](,[ds])'), r'$1'),
  // 夫妻的对方是自己
  FilterRule(RegExp(r',w,h|,h,w'), ''),
  // 并列关系处理1 X[A|B|C]Y = XAY#X[B|C]Y
  FilterRule(
    RegExp(r'(.+)?\[([^\|]+?)\|([^\[\]]*\|[^\[\]]*)\](.+)?'),
    r'$1$2$4#$1[$3]$4',
  ),
  // 并列关系处理2 X[A|B]Y = XAY#XBY
  FilterRule(
    RegExp(r'(.+)?\[([^\[\]\|]+?)\|([^\[\]\|]+?)?\](.+)?'),
    r'$1$2$4#$1$3$4',
  ),
];
