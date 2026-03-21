/// 自然语言表达 - 将语言表达转换成参数调用
class ExpressionRule {
  final RegExp exp;
  final Map<String, dynamic> Function(RegExpMatch match) opt;
  const ExpressionRule(this.exp, this.opt);
}

final List<ExpressionRule> expressionRules = [
  ExpressionRule(
    RegExp(r'^(\S+?)(应该|得)?(称呼|叫|喊)(\S+?)(什么|啥)？?$'),
    (match) => {'text': match.group(4), 'target': match.group(1)},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(应该|得)?(如何|怎么)(称呼|叫|喊)(\S+?)？?$'),
    (match) => {'text': match.group(5), 'target': match.group(1)},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)是(\S+?)的(谁|什么|什么亲戚|啥亲戚|什么人)？?$'),
    (match) => {
      'text': match.group(1),
      'target': match.group(2),
      'type': match.group(1)!.contains('的') ? 'default' : 'chain',
    },
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(应该|得)?管(\S+?)叫(什么|啥)？?$'),
    (match) => {'text': match.group(3), 'target': match.group(1)},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(和|与)(\S+?)(之间)?是(什么|啥)关系？?$'),
    (match) => {
      'text': match.group(1),
      'target': match.group(3),
      'type': 'pair',
    },
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)对于(\S+?)是(什么|啥)关系？?$'),
    (match) => {
      'text': match.group(1),
      'target': match.group(2),
      'type': 'chain',
    },
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(指的)?是(什么|啥)(意思|关系|亲戚关系|辈分|人)？?$'),
    (match) => {'text': match.group(1), 'type': 'chain'},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(应该|得)?(称呼|叫|喊)(什么|啥)？?$'),
    (match) => {'text': match.group(1)},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)(应该|得)?(如何|怎么)(称呼|叫|喊)？?$'),
    (match) => {'text': match.group(1)},
  ),
  ExpressionRule(
    RegExp(r'^(\S+?)是(谁|什么|什么亲戚|啥亲戚|什么人|什么辈分|啥辈分)？?$'),
    (match) => {
      'text': match.group(1),
      'type': match.group(1)!.contains('的') ? 'default' : 'chain',
    },
  ),
];
