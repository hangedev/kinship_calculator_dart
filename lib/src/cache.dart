// 缓存数据 - 名称到关系链ID的反向查找
import 'data/input_data.dart';
import 'data/sort_data.dart';
import 'mode.dart';

Map<String, List<String>> _buildCacheData() {
  // Merge modeData + inputData + sortData
  final hash = Map<String, List<String>>.of(modeData);
  for (final entry in inputData.entries) {
    hash[entry.key] = [...(hash[entry.key] ?? []), ...entry.value];
  }
  for (final entry in sortData.entries) {
    hash[entry.key] = [...(hash[entry.key] ?? []), ...entry.value];
  }

  // Build reverse lookup: name → [keys]
  final cache = <String, List<String>>{};
  for (final entry in hash.entries) {
    for (final name in entry.value) {
      if (!cache.containsKey(name)) {
        cache[name] = [];
      }
      cache[name]!.add(entry.key);
    }
  }
  return cache;
}

final Map<String, List<String>> cacheData = _buildCacheData();
