// 模式数据
import 'map.dart' as map_module;

final Map<String, Map<String, List<String>>> _mode = {};
Map<String, List<String>> modeData = Map.of(map_module.builtMap);

/// 设置模式数据
void setModeData(String sign, Map<String, List<String>> data) {
  _mode[sign] = {...(_mode[sign] ?? {}), ...data};
}

/// 获取模式数据
Map<String, List<String>> getModeData(String sign) {
  modeData = Map.of(map_module.builtMap);
  if (sign.isNotEmpty && _mode.containsKey(sign)) {
    for (final key in _mode[sign]!.keys) {
      modeData[key] = [
        ..._mode[sign]![key]!,
        ...(map_module.builtMap[key] ?? []),
      ];
    }
  }
  return modeData;
}
