// 完整关系链数据 - 合并各类关系链数据
import 'data/prefix_data.dart';
import 'data/branch_data.dart';
import 'data/main_data.dart';
import 'data/multiple_data.dart';
import 'selector.dart';
import 'unit.dart';

final Map<String, List<String>> builtMap = _buildMap();

Map<String, List<String>> _buildMap() {
  // Deep copy multipleData so all lists are mutable
  final map = <String, List<String>>{
    for (final e in multipleData.entries) e.key: List<String>.of(e.value),
  };

  // 分支 - 前缀处理
  final prefixMap = <String, Map<String, List<String>>>{};
  for (final key in prefixData.keys) {
    prefixMap[key] = {};
    for (final selector in prefixData[key]!.keys) {
      for (final s in expandSelector(selector)) {
        prefixMap[key]![s] = prefixData[key]![selector]!;
      }
    }
  }

  // 分支 - 节点处理
  final branchMap2 = <String, List<String>>{};
  for (final selector in branchData.keys) {
    for (final s in expandSelector(selector)) {
      branchMap2[s] = branchData[selector]!;
    }
  }

  // 分支 - 合并
  Map<String, List<String>> getMap(
    Map<String, Map<String, List<String>>> prefixMap,
    Map<String, List<String>> branchMap,
  ) {
    final result = <String, List<String>>{};
    for (final key in branchMap.keys) {
      final tagMatch = RegExp(r'\{.+?\}').firstMatch(key);
      if (tagMatch == null) continue;
      final tag = tagMatch.group(0)!;
      final nameList = branchMap[key]!;
      if (!prefixMap.containsKey(tag)) continue;
      for (final k in prefixMap[tag]!.keys) {
        final prefixList = prefixMap[tag]![k]!;
        final newKey = key.replaceAll(tag, k);
        final isFilter = ['h,h', 'w,w', 'w,h', 'h,w']
            .any((pair) => newKey.contains(pair));
        if (!isFilter) {
          final newList = prefixList.expand((prefix) {
            return nameList.map((name) =>
                name.contains('?') ? name.replaceAll('?', prefix) : prefix + name);
          }).toList();
          if (!result.containsKey(newKey)) {
            result[newKey] = map[newKey] != null ? List.of(map[newKey]!) : [];
          }
          result[newKey] = [...newList, ...result[newKey]!];
        }
      }
    }
    return result;
  }

  final merged = getMap(prefixMap, branchMap2);
  map.addAll(merged);

  // 主要关系
  for (final key in mainData.keys) {
    map[key] = [...mainData[key]!, ...(map[key] ?? [])];
  }

  // 版权彩蛋
  map['o'] = ['passer-by.com', '\u4f5c\u8005'];

  // 配偶关系
  final mateMap = <String, List<String>>{
    'w': ['妻', '内', '岳', '岳家', '丈人'],
    'h': ['夫', '外', '公', '婆家', '婆婆'],
  };
  final nameSet = <String>{};
  for (final names in map.values) {
    nameSet.addAll(names);
  }
  // Need to iterate over a snapshot of keys to avoid concurrent modification
  final mapKeys = map.keys.toList();
  for (final key in mapKeys) {
    if (RegExp(r'^[fm]').hasMatch(key) ||
        RegExp(r'^[olx][bs]$|^[olx][bs],[^mf]').hasMatch(key)) {
      for (final k in mateMap.keys) {
        final newKey = '$k,$key';
        if (RegExp(r'[fm]').hasMatch(key)) {
          final newKeyX = regReplace(
              regReplace(newKey, RegExp(r',[ol]([sb])(,[wh])?$'), r',x$1$2'),
              RegExp(r'(,[sd])&[ol](,[wh])?$'), r'$1$2');
          if (newKeyX != newKey && map.containsKey(newKeyX)) {
            continue;
          }
        }
        if (!map.containsKey(newKey)) {
          map[newKey] = [];
        }
        final prefixList = mateMap[k]!;
        final nameList = map[key]!;
        for (final prefix in prefixList) {
          for (final name in nameList) {
            final newName = prefix + name;
            if (!nameSet.contains(newName)) {
              map[newKey]!.add(newName);
            }
          }
        }
      }
    }
  }

  return map;
}
