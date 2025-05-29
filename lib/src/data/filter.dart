/*
 * 关系链缩写规则 - 将【关系链】缩减成最简表达
 *
 * 关系数据语法说明：
 * 【关系符】 f:父; m:母; h:夫; w:妻; s:子; d:女; xb:兄弟; ob:兄; lb:弟; xs:姐妹; os:姐; ls:妹
 * 【修饰符】 1:男性; 0:女性; &o:年长; &l:年幼; &\d+:排序 #:隔断; [a|b]:并列
 */
final List<Map<String, dynamic>> filterData = [
  /* 表亲 */
  {
    //表亲的关系
    'exp': r'^(.+)&o([^#]+)&l/g',
    'str': (Match m) {
      return '${m[1]}${m[2]}';
    }
  },
  {
    //表亲的关系
    'exp': r'^(.+)&l([^#]+)&o/g',
    'str': (Match m) {
      return '${m[1]}${m[2]}';
    }
  },
  {
    //表亲的关系
    'exp': r'(,[ds],(.+),[ds])&[ol]/g',
    'str': (Match m) {
      return '${m[1]}';
    }
  },
/* 兄弟姐妹 */
  {
    //哥哥姐姐的哥哥姐姐还是自己的哥哥姐姐(年龄判断)
    'exp': r'(,o[sb])+(,o[sb])',
    'str': (Match m) {
      return '${m[2]}';
    }
  },
  {
    //弟弟妹妹的弟弟妹妹还是自己的弟弟妹妹(年龄判断)
    'exp': r'(,l[sb])+(,l[sb])',
    'str': (Match m) {
      return '${m[2]}';
    }
  },
  {
    //如果自己是男性,兄弟姐妹的兄弟就是自己的兄弟或自己
    'exp': r'^(.*)(,[fh1])(,[olx][sb])+,[olx]b(.*)$',
    'str': (Match m) {
      return '${m[1]}${m[2]},xb${m[4]}#${m[1]}${m[2]}${m[4]}';
    }
  },
  {
    //如果自己是女性,兄弟姐妹的姐妹就是自己的姐妹或自己
    'exp': r'^(.*)(,[mw0])(,[olx][sb])+,[olx]s(.*)$',
    'str': (Match m) {
      return '${m[1]}${m[2]},xs${m[4]}#${m[1]}${m[2]}${m[4]}';
    }
  },
  {
    //如果自己是男性,兄弟姐妹的姐妹就是自己的姐妹
    'exp': r'(,[fh1])(,[olx][sb])+,[olx]s/g',
    'str': (Match m) {
      return '${m[1]},xs';
    }
  },
  {
    //如果自己是女性,兄弟姐妹的兄弟就是自己的兄弟
    'exp': r'(,[mw0])(,[olx][sb])+,[olx]b/g',
    'str': (Match m) {
      return '${m[1]},xb';
    }
  },
  {
    //不知道性别，兄弟姐妹的兄弟是自己或兄弟
    'exp': r'^,[olx][sb],[olx]b(.+)?$',
    'str': (Match m) {
      return '${m[1]}#,xb${m[1]}';
    }
  },
  {
    //不知道性别，兄弟姐妹的姐妹是自己或姐妹
    'exp': r'^,[olx][sb],[olx]s(.+)?$',
    'str': (Match m) {
      return '${m[1]}#,xs${m[1]}';
    }
  },
  {
    //将复合称谓拆分
    'exp': r'^,x([sb])$',
    'str': (Match m) {
      return ',o${m[1]}#,l${m[1]}';
    }
  },
/* 父母 */
  {
    //母亲的丈夫是自己的父亲
    'exp': r'm,h/g',
    'str': (Match m) {
      return 'f';
    }
  },
  {
    //父亲的妻子是自己的母亲
    'exp': r'f,w/g',
    'str': (Match m) {
      return 'm';
    }
  },
  {
    //兄弟的父母就是自己的父母
    'exp': r',[xol][sb](,[mf])/g',
    'str': (Match m) {
      return '${m[1]}';
    }
  },
/* 父母的子女 */
  {
    //父母的女儿年龄判断是姐姐还是妹妹
    'exp': r',[mf],d&([ol])',
    'str': (Match m) {
      return ',${m[1]}s';
    }
  },
  {
    //父母的儿子年龄判断是哥哥还是弟弟
    'exp': r',[mf],s&([ol])',
    'str': (Match m) {
      return ',${m[1]}b';
    }
  },
  {
    //如果自己是男性,父母的儿子是自己或者兄弟
    'exp': r'^(.*)(,[fh1]|[xol]b),[mf],s(.*)$',
    'str': (Match m) {
      return '${m[1]}${m[2]},xb${m[3]}#${m[1]}${m[2]}${m[3]}';
    }
  },
  {
    //如果自己是女性,父母的女儿是自己或者姐妹
    'exp': r'^(.*)(,[mw0]|[xol]s),[mf],d(.*)$',
    'str': (Match m) {
      return '${m[1]}${m[2]},xs${m[3]}#${m[1]}${m[2]}${m[3]}';
    }
  },
  {
    //如果自己是女性,父母的儿子是自己兄弟
    'exp': r'(,[mw0]|[xol]s),[mf],s',
    'str': (Match m) {
      return '${m[1]},xb';
    }
  },
  {
    //如果自己是男性,父母的女儿是自己姐妹
    'exp': r'(,[fh1]|[xol]b),[mf],d',
    'str': (Match m) {
      return '${m[1]},xs';
    }
  },
  {
    //父母的儿子是自己或兄弟
    'exp': r'^,[mf],s(.+)?$',
    'str': (Match m) {
      return ',1${m[1]}#,xb${m[1]}';
    }
  },
  {
    //父母的女儿是自己或者姐妹
    'exp': r'^,[mf],d(.+)?$',
    'str': (Match m) {
      return ',0${m[1]}#,xs${m[1]}';
    }
  },
/* 孩子 */
  {
    //孩子的姐妹是自己的女儿(年龄判断)
    'exp': r',[ds]&o,ob/g',
    'str': (Match m) {
      return ',s&o';
    }
  },
  {
    //孩子的姐妹是自己的女儿(年龄判断)
    'exp': r',[ds]&o,os/g',
    'str': (Match m) {
      return ',d&o';
    }
  },
  {
    //孩子的兄弟是自己的儿子(年龄判断)
    'exp': r',[ds]&l,lb/g',
    'str': (Match m) {
      return ',s&l';
    }
  },
  {
    //孩子的兄弟是自己的儿子(年龄判断)
    'exp': r',[ds]&l,ls/g',
    'str': (Match m) {
      return ',d&l';
    }
  },
  {
    //孩子的姐妹是自己的女儿
    'exp': r',[ds](&[ol])?,[olx]s/g',
    'str': (Match m) {
      return ',d';
    }
  },
  {
    //孩子的兄弟是自己的儿子
    'exp': r',[ds](&[ol])?,[olx]b/g',
    'str': (Match m) {
      return ',s';
    }
  },
/* 夫妻 */
  {
    //自己是女性，女儿或儿子的妈妈是自己
    'exp': r'(,[mwd0](&[ol])?|[olx]s),[ds](&[ol])?,m/g',
    'str': (Match m) {
      return '${m[1]}';
    }
  },
  {
    //自己是女性，女儿或儿子的爸爸是自己的丈夫
    'exp': r'(,[mwd0](&[ol])?|[olx]s),[ds](&[ol])?,f/g',
    'str': (Match m) {
      return '${m[1]},h';
    }
  },
  {
    //自己是男性，女儿或儿子的爸爸是自己
    'exp': r'(,[fhs1](&[ol])?|[olx]b),[ds](&[ol])?,f/g',
    'str': (Match m) {
      return '${m[1]}';
    }
  },
  {
    //自己是男性，女儿或儿子的妈妈是自己的妻子
    'exp': r'(,[fhs1](&[ol])?|[olx]b),[ds](&[ol])?,m/g',
    'str': (Match m) {
      return '${m[1]},w';
    }
  },
  {
    //不知道性别，子女的妈妈是自己或妻子
    'exp': r'^,[ds],m(.+)?$',
    'str': (Match m) {
      return '${m[1]}#,w${m[1]}';
    }
  },
  {
    //不知道性别，子女的爸爸是自己或丈夫
    'exp': r'^,[ds],f(.+)?$',
    'str': (Match m) {
      return '${m[1]}#,h${m[1]}';
    }
  },
  {
    //夫妻的孩子就是自己的孩子
    'exp': r',[wh](,[ds])/g',
    'str': (Match m) {
      return '${m[1]}';
    }
  },
  {
    //夫妻的对方是自己
    'exp': r',w,h|,h,w/g',
    'str': (Match m) {
      return '';
    }
  },
  {
    //并列关系处理
    'exp': r'(.+)?\[(.+)\|(.+)\](.+)?/g',
    'str': (Match m) {
      return '${m[1]}${m[2]}${m[4]}#${m[1]}${m[3]}${m[4]}';
    }
  }
];
