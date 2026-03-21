// 标识符 - 唯一性关系链，将【关系链】转换成【中文表述】
import 'data/pair_data.dart';
import 'data/sort_data.dart';
import 'unit.dart';
import 'selector.dart';
import 'mode.dart';

/// 逆转ID
List<String> reverseId(String id, int sex) {
  if (id.isEmpty) {
    return [''];
  }
  // 映射关系
  final hash = <String, List<String>>{
    'f': ['d', 's'],
    'm': ['d', 's'],
    'h': ['w', ''],
    'w': ['', 'h'],
    's': ['m', 'f'],
    'd': ['m', 'f'],
    'lb': ['os', 'ob'],
    'ob': ['ls', 'lb'],
    'xb': ['xs', 'xb'],
    'ls': ['os', 'ob'],
    'os': ['ls', 'lb'],
    'xs': ['xs', 'xb'],
  };
  // 年纪判断
  String age = '';
  if (RegExp(r'&o$').hasMatch(id)) {
    age = '&l';
  } else if (RegExp(r'&l$').hasMatch(id)) {
    age = '&o';
  }
  id = id.replaceAll(RegExp(r'&[ol\d+]'), '');
  // 性别判断
  if (sex < 0) {
    if (RegExp(r'^w').hasMatch(id)) {
      sex = 1;
    } else if (RegExp(r'^h').hasMatch(id)) {
      sex = 0;
    }
  }

  String doing(int sex) {
    final sid = (',$sex,$id')
        .replaceAll(RegExp(r',[fhs]|,[olx]b'), ',1')
        .replaceAll(RegExp(r',[mwd]|,[olx]s'), ',0');
    final sidArr = sid.substring(0, sid.length - 2).split(',').reversed.toList();
    final rId = id.split(',').reversed.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final part = entry.value;
      return hash[part]![int.parse(sidArr[i])];
    }).join(',');
    final gen = getGenById(rId);
    return rId + (gen != 0 ? '' : age);
  }

  if (sex < 0) {
    return [doing(1), doing(0)];
  } else {
    return [doing(sex)];
  }
}

/// ID列表去重
List<String> filterId(List<String> arr) {
  final sameList = arr.where((item) =>
      item ==
      item
          .replaceAll(RegExp(r'[ol](?=[s|b])'), 'x')
          .replaceAll(RegExp(r'&[ol]'), '')).toList();
  return arr.where((item) {
    final temp = item
        .replaceAll(RegExp(r'[ol](?=[s|b])'), 'x')
        .replaceAll(RegExp(r'&[ol]'), '');
    return sameList.contains(item) ||
        item != temp && !sameList.contains(temp);
  }).toSet().toList();
}

/// 通过ID获取世代数
int getGenById(String id) {
  const gMap = {'f': 1, 'm': 1, 's': -1, 'd': -1};
  int gen = 0;
  for (final sub in id.split(',')) {
    final s = sub.replaceAll(RegExp(r'&[ol\d]+'), '');
    gen += gMap[s] ?? 0;
  }
  return gen;
}

/// 通过ID获取关系称呼
List<String> getItemsById(String id) {
  List<String> items = [];

  List<String> getData(String key) {
    List<String> ids = [];
    final k1 = regReplace(key, RegExp(r'(,[sd])(,[wh])?$'), r'$1&o$2');
    final k2 = regReplace(key, RegExp(r'(,[sd])(,[wh])?$'), r'$1&l$2');
    if (modeData.containsKey(k1) && modeData.containsKey(k2)) {
      ids = [k1, k2];
    } else if (modeData.containsKey(key)) {
      ids = [key];
    }
    return filterId(ids).map((id) => modeData[id]![0]).toList();
  }

  // 对排序进行处理
  final sortMatch = RegExp(r'&([\d]+)(,[hw])?$').firstMatch(id);
  if (sortMatch != null) {
    final num = sortMatch.group(1)!;
    final zh = number2zh(int.parse(num));
    id = id.replaceAll(RegExp(r'&\d+'), '');
    if (sortData.containsKey(id)) {
      items.add(sortData[id]![0].replaceAll('几', zh));
    } else if (modeData.containsKey(id)) {
      final gen = getGenById(id);
      String item = '';
      if (gen < 3 && !RegExp(r'[hw],').hasMatch(id)) {
        for (final name in modeData[id]!) {
          if (item.isEmpty && name.contains('几')) {
            item = name.replaceAll('几', zh);
          }
        }
        if (item.isEmpty) {
          item = modeData[id]![0];
          item = RegExp(r'^[大小]').hasMatch(item)
              ? item.replaceFirst(RegExp(r'^[大小]'), zh)
              : zh + item;
        }
      }
      items.add(item);
    }
  }
  // 直接匹配称呼
  if (items.isEmpty) {
    id = id.replaceAll(RegExp(r'&\d+'), '');
    items = getData(id);
  }
  // 忽略年龄条件查找
  if (items.isEmpty) {
    id = id.replaceAll(RegExp(r'&[ol]'), '');
    items = getData(id);
  }
  // 忽略年龄条件查找
  if (items.isEmpty) {
    id = regReplace(id, RegExp(r'[ol](b|s)'), r'x$1');
    items = getData(id);
  }
  // 缩小访问查找
  if (items.isEmpty) {
    final l = id.replaceAll('x', 'l');
    final o = id.replaceAll('x', 'o');
    items = [...items, ...getData(o), ...getData(l)];
  }
  return items;
}

/// 通过ID获取关系链
String getChainById(String id, [int sex = -1]) {
  // Rebuild chain data from current modeData each time
  final data = Map<String, List<String>>.of(modeData);
  data['xb'] = ['兄弟'];
  data['xs'] = ['姐妹'];

  String item = id.split(',').map((sign) {
    final key = sign.replaceAll(RegExp(r'&[ol\d]+'), '');
    return data[key]![0];
  }).join('的');
  if (sex > -1 && data.containsKey('$sex,$id')) {
    if (sex == 0) {
      item = '(女性)$item';
    } else if (sex == 1) {
      item = '(男性)$item';
    }
  }
  return item;
}

/// 通过ID获取关系合称
List<String> getPairsById(String id1, String id2) {
  id1 = id1.replaceAll(RegExp(r'&\d+'), '');
  id2 = id2.replaceAll(RegExp(r'&\d+'), '');
  final id1X = regReplace(id1, RegExp(r'([ol])([bs])'), r'x$2');
  final id2X = regReplace(id2, RegExp(r'([ol])([bs])'), r'x$2');
  final id1R = id1.replaceAll(RegExp(r'&[ol]'), '');
  final id2R = id2.replaceAll(RegExp(r'&[ol]'), '');

  List<String> result = [];
  List<String> resultX = [];
  List<String> resultR = [];
  for (final key in pairData.keys) {
    final selectors = key.split('#');
    if (selectors.length > 1) {
      final list1 = selector2id(selectors[0]);
      final list2 = selector2id(selectors[1]);
      final list1R = list1
          .map((s) => regReplace(
              s.replaceAll(RegExp(r'&[ol\d]+'), ''),
              RegExp(r'([ol])([bs])'), r'x$2'))
          .toList();
      final list2R = list2
          .map((s) => regReplace(
              s.replaceAll(RegExp(r'&[ol\d]+'), ''),
              RegExp(r'([ol])([bs])'), r'x$2'))
          .toList();
      if ((list1.contains(id1) && list2.contains(id2)) ||
          (list1.contains(id2) && list2.contains(id1))) {
        result.add(pairData[key]![0]);
      }
      if ((list1R.contains(id1X) && list2R.contains(id2X)) ||
          (list1R.contains(id2X) && list2R.contains(id1X))) {
        resultX.add(pairData[key]![0]);
      }
      if ((list1R.contains(id1R) && list2R.contains(id2R)) ||
          (list1R.contains(id2R) && list2R.contains(id1R))) {
        resultR.add(pairData[key]![0]);
      }
    }
  }
  if (result.isEmpty) {
    result = resultX;
  }
  if (result.isEmpty) {
    result = resultR;
  }
  return result;
}
