// 通过表达式获取配置
import 'rule/expression_rule.dart';

Map<String, dynamic> getOptions(String text) {
  for (final item in expressionRules) {
    final match = item.exp.firstMatch(text);
    if (match != null) {
      return item.opt(match);
    }
  }
  return {};
}
