// 中文亲戚关系计算
import 'options.dart';
import 'selector.dart';
import 'id.dart';
import 'mode.dart';

/// Calculate Chinese kinship relationships.
///
/// [text] - Target relationship description (e.g., '爸爸的妈妈的哥哥')
/// [target] - Relative object description, empty means self
/// [sex] - Gender: 0=female, 1=male, -1=unknown
/// [type] - Calculation type: 'default', 'chain', or 'pair'
/// [reverse] - true=how other calls me, false=how I call other
/// [mode] - Regional mode name (use setRelationshipMode to register custom modes)
/// [optimal] - Calculate shortest relationship path
List<String> relationship({
  required String text,
  String target = '',
  int sex = -1,
  String type = 'default',
  bool reverse = false,
  String mode = 'default',
  bool optimal = false,
}) {
  // 切换模式
  getModeData(mode);

  final fromSelectors = getSelectors(text);
  List<String> toSelectors = getSelectors(target);
  if (toSelectors.isEmpty) {
    toSelectors = [''];
  }

  final result = fromSelectors.expand((fromSelector) {
    return toSelectors.expand((toSelector) {
      return mergeSelector({
        'from': fromSelector,
        'to': toSelector,
        'sex': sex,
        'optimal': optimal,
      }).expand((data) {
        final ids = selector2id(
            data['selector'] as String, data['sex'] as int);
        return ids.expand((id) {
          List<String> temps = [id];
          int s = data['sex'] as int;
          if (reverse) {
            temps = reverseId(id, s);
            if (RegExp(r'([fhs1](&[ol\d]+)?|[olx]b)$').hasMatch(id)) {
              s = 1;
            } else {
              s = 0;
            }
          }
          if (type == 'chain') {
            return temps
                .map((id) => getChainById(id, s))
                .where((item) => item.isNotEmpty);
          } else if (type == 'pair') {
            final reversedTemps = reverseId(id, data['sex'] as int);
            return reversedTemps.expand((rId) => getPairsById(id, rId));
          } else {
            return temps.expand((id) {
              List<String> items = getItemsById(id);
              if (items.isEmpty) {
                items = getItemsById('$s,$id');
              }
              return items;
            });
          }
        });
      });
    });
  }).toList();

  return result.toSet().toList();
}

/// Parse natural language expression and calculate relationship.
/// Supports patterns like: 'xxx是xxx的什么人', 'xxx叫xxx什么', etc.
List<String> relationshipFromExpression(String expression) {
  final options = getOptions(expression);
  if (options.isEmpty) return [];
  return relationship(
    text: (options['text'] as String?) ?? '',
    target: (options['target'] as String?) ?? '',
    sex: (options['sex'] as int?) ?? -1,
    type: (options['type'] as String?) ?? 'default',
    reverse: (options['reverse'] as bool?) ?? false,
    mode: (options['mode'] as String?) ?? 'default',
    optimal: (options['optimal'] as bool?) ?? false,
  );
}

/// Register a custom regional mode
void setRelationshipMode(String name, Map<String, List<String>> data) {
  setModeData(name, data);
}

/// Get current relationship data map
Map<String, List<String>> get relationshipData => modeData;

/// Get current data count
int get relationshipDataCount => modeData.length;
