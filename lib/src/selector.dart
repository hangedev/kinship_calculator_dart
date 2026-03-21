// 选择器 - 非唯一性关系链，将【中文表述】转换为【关系链】
import 'rule/filter_rule.dart';
import 'rule/replace_rule.dart';
import 'rule/similar_rule.dart';
import 'unit.dart';
import 'id.dart';
import 'cache.dart';

/// 获得最简
Map<String, dynamic> _getOptimal(Map<String, dynamic> options) {
  String from = options['from'] as String;
  String to = options['to'] as String;
  int sex = options['sex'] as int;
  final fromChain = from.split(',');
  final toChain = to.split(',');
  for (int i = 0; i < fromChain.length && i < toChain.length; i++) {
    if (fromChain[i] == toChain[i]) {
      from = fromChain.sublist(i + 1).join(',');
      to = toChain.sublist(i + 1).join(',');
      sex = RegExp(r'^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?')
              .hasMatch(fromChain[i])
          ? 1
          : 0;
      continue;
    } else {
      if (getGenById(fromChain[i]) == getGenById(toChain[i]) &&
          RegExp(r'^[xol][bs]|^[sd]').hasMatch(fromChain[i]) &&
          RegExp(r'^[xol][bs]|^[sd]').hasMatch(toChain[i])) {
        final formType = regReplaceFirst(
            fromChain[i].replaceAll(RegExp(r'&([ol\d]+)'), ''),
            RegExp(r'^[xol]([bs])'), r'$1');
        final toType = regReplaceFirst(
            toChain[i].replaceAll(RegExp(r'&([ol\d]+)'), ''),
            RegExp(r'^[xol]([bs])'), r'$1');
        if (formType != toType) {
          break;
        }
        final fromAttr =
            RegExp(r'&([ol\d]+)').firstMatch(fromChain[i])?.group(1) ??
                RegExp(r'([ol])[bs]').firstMatch(fromChain[i])?.group(1) ??
                '';
        final toAttr =
            RegExp(r'&([ol\d]+)').firstMatch(toChain[i])?.group(1) ??
                RegExp(r'([ol])[bs]').firstMatch(toChain[i])?.group(1) ??
                '';
        if (fromAttr.isNotEmpty && toAttr.isNotEmpty) {
          final fromNum = int.tryParse(fromAttr);
          final toNum = int.tryParse(toAttr);
          if (fromNum != null && toNum != null) {
            if (fromNum > toNum) {
              fromChain[i] = fromChain[i]
                  .replaceFirst(RegExp(r'^[xol]b|^s'), 'lb')
                  .replaceFirst(RegExp(r'^[xol]s|^d'), 'ls');
            } else if (fromNum < toNum) {
              fromChain[i] = fromChain[i]
                  .replaceFirst(RegExp(r'^[xol]b|^s'), 'ob')
                  .replaceFirst(RegExp(r'^[xol]s|^d'), 'os');
            }
          } else if (fromNum != null && toAttr == 'o' ||
              fromAttr == 'l' && toNum != null) {
            fromChain[i] = fromChain[i]
                .replaceFirst(RegExp(r'^[xol]b|^s'), 'lb')
                .replaceFirst(RegExp(r'^[xol]s|^d'), 'ls');
          } else if (fromNum != null && toAttr == 'l' ||
              fromAttr == 'o' && toNum != null) {
            fromChain[i] = fromChain[i]
                .replaceFirst(RegExp(r'^[xol]b|^s'), 'ob')
                .replaceFirst(RegExp(r'^[xol]s|^d'), 'os');
          }
          from = fromChain.sublist(i).join(',');
          to = toChain.sublist(i + 1).join(',');
          sex = RegExp(r'^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?')
                  .hasMatch(toChain[i])
              ? 1
              : 0;
        } else if (options['optimal'] == true) {
          final fromAttr2 =
              RegExp(r'([xol])[bs]').firstMatch(fromChain[i])?.group(1) ?? '';
          final toAttr2 =
              RegExp(r'([xol])[bs]').firstMatch(toChain[i])?.group(1) ?? '';
          if (fromAttr2 == 'x' || toAttr2 == 'x') {
            from = fromChain.sublist(i + 1).join(',');
            to = toChain.sublist(i + 1).join(',');
            sex = RegExp(r'^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?')
                    .hasMatch(fromChain[i])
                ? 1
                : 0;
            continue;
          }
        }
      }
      break;
    }
  }
  return {'from': from, 'to': to, 'sex': sex};
}

/// 中文获取选择器
List<String> getSelectors(String str) {
  str = str.replaceAll('之', '的');
  str = regReplace(str, RegExp(r'吾之?(.+)'), r'$1');
  str = regReplace(str, RegExp(r'我的?(.+)'), r'$1');
  // 惯用口语标准化
  if (RegExp(r'[^娘婆岳亲]家的?(孩子|儿子|女儿)').hasMatch(str)) {
    str = str.replaceFirst(RegExp(r'家的?'), '的');
  }
  str = regReplaceFirst(str,
      RegExp(r'(舅|姑)+(爸|父|丈|妈|母)?家的?(哥|姐|弟|妹)+'), r'$1表$3');
  str = regReplaceFirst(str,
      RegExp(r'(舅|姑)+(爸|父|丈|妈|母)?家的?'), r'$1表');
  str = regReplaceFirst(str,
      RegExp(r'(伯|叔)+(父|母)?家的?(哥|姐|弟|妹)+'), r'堂$3');
  str = str.replaceFirst(RegExp(r'(伯|叔)+(父|母)?家的?'), '堂');
  str = regReplaceFirst(str,
      RegExp(r'姨+(爸|父|丈|妈|母)?家的?(哥|姐|弟|妹)+'), r'姨$2');
  str = str.replaceFirst(RegExp(r'姨+(爸|父|丈|妈|母)?家的?'), '姨');

  final lists = str.split('的');
  List<String> result = [];
  bool isMatch = true;

  while (lists.isNotEmpty) {
    final name = lists.removeAt(0);
    List<String> items = [];
    final keywords = <String>[name];

    void getList(String name) {
      // 词义扩展
      for (final item in replaceRules) {
        for (final word in item.arr) {
          final name1 = name.replaceFirst(item.exp, word);
          if (name1 != name) {
            keywords.add(name1);
            getList(name1);
          }
        }
      }
      // 同义词替换
      for (final word in similarMap.keys) {
        final name1 = name.replaceAll(word, similarMap[word]!);
        final name2 = name.replaceAll(similarMap[word]!, word);
        if (name1 != name) {
          keywords.add(name1);
        }
        if (name2 != name) {
          keywords.add(name2);
        }
      }
    }

    getList(name);

    // 通过关键词找关系
    final itemsMap = <List<String>>[[], [], []];
    for (final kw in keywords) {
      String n = kw.replaceFirst(RegExp(r'^[尕幺细满碎晚末尾幼]'), '小');
      final match = RegExp(r'^[大|小]|^[一|二|三|四|五|六|七|八|九|十]+').firstMatch(n);
      if (match != null) {
        final xName = n.replaceFirst(match.group(0)!, '几');
        final rName = n.replaceFirst(match.group(0)!, '');
        final num = zh2number(match.group(0)!);
        final names = [xName, rName, n];
        for (int index = 0; index < names.length; index++) {
          final ids = cacheData[names[index]];
          if (ids != null && ids.isNotEmpty) {
            for (final i in ids) {
              final id = regReplaceFirst(
                  regReplaceFirst(i, RegExp(r'(,[hw])$'), '&$num\$1'),
                  RegExp(r'([^hw]+)$'), '\$1&$num');
              if (!RegExp(r'^[mf,]+$').hasMatch(i) &&
                  !RegExp(r'^[从世]').hasMatch(names[index])) {
                itemsMap[index].add(id);
              }
            }
          }
        }
      }
      items = [...items, ...(cacheData[kw] ?? [])];
    }
    // 如找不到结果，再是否存在称呼的排行问题
    for (final itemsX in itemsMap) {
      if (items.isEmpty) {
        items = itemsX;
      }
    }
    // 完全匹配不到结果
    if (items.isEmpty) {
      isMatch = false;
    }
    final res = <String>[];
    if (result.isEmpty) {
      result = [''];
    }
    for (final a in result) {
      for (final b in items) {
        res.add(a + (b.isNotEmpty ? ',$b' : ''));
      }
    }
    result = res;
  }
  return isMatch ? filterId(result) : [];
}

/// 合并选择器，查找两个对象之间的关系
List<Map<String, dynamic>> mergeSelector(Map<String, dynamic> param) {
  String fromSelector = param['from'] as String;
  String toSelector = param['to'] as String;
  int mySex = param['sex'] as int;

  if (mySex < 0) {
    final fromSex = RegExp(r'^,[w1]').hasMatch(fromSelector)
        ? 1
        : RegExp(r'^,[h0]').hasMatch(fromSelector)
            ? 0
            : -1;
    final toSex = RegExp(r'^,[w1]').hasMatch(toSelector)
        ? 1
        : RegExp(r'^,[h0]').hasMatch(toSelector)
            ? 0
            : -1;
    if (fromSex == -1 && toSex > -1) {
      mySex = toSex;
    } else if (fromSex > -1 && toSex == -1) {
      mySex = fromSex;
    } else if (fromSex == toSex) {
      mySex = fromSex;
    } else {
      return [];
    }
  }

  final fromIds = selector2id(param['from'] as String, mySex);
  final toIds = selector2id(param['to'] as String, mySex);
  if (fromIds.isEmpty || toIds.isEmpty) {
    return [];
  }

  final result = <Map<String, dynamic>>[];
  for (final from0 in fromIds) {
    for (final to0 in toIds) {
      String from = from0;
      String to = to0;
      int sex = mySex;
      String selector = ',$to';
      if (RegExp(r',([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?$')
          .hasMatch(selector)) {
        sex = 1;
      }
      if (RegExp(r',([mwd0](&[ol\d]+)?|[olx]s)(&[ol\d]+)?$')
          .hasMatch(selector)) {
        sex = 0;
      }
      if (from.isNotEmpty && to.isNotEmpty) {
        bool isOptimal = param['optimal'] == true;
        if (RegExp(r'&\d+').hasMatch(from) || RegExp(r'&\d+').hasMatch(to)) {
          isOptimal = true;
        }
        if (isOptimal) {
          final opt = _getOptimal({
            'from': from,
            'to': to,
            'sex': mySex,
            'optimal': param['optimal'] == true,
          });
          from = opt['from'] as String;
          to = opt['to'] as String;
          mySex = opt['sex'] as int;
        }
      }
      final toRids = to.isNotEmpty ? reverseId(to, mySex) : [''];
      for (final toR in toRids) {
        final sel = (toR.isNotEmpty ? ',$toR' : '') +
            (from.isNotEmpty ? ',$from' : '');
        result.add({'selector': sel, 'sex': sex});
      }
    }
  }
  return result;
}

/// 扩展选择器
List<String> expandSelector(String selector) {
  final result = <String>[];
  final hash = <String, bool>{};

  bool getSelector(String selector) {
    if (hash[selector] != true) {
      hash[selector] = true;
      String s;
      do {
        s = selector;
        for (final item in filterRules) {
          if (item.global) {
            selector = regReplace(selector, item.exp, item.str);
          } else {
            selector = regReplaceFirst(selector, item.exp, item.str);
          }
          if (selector.contains('#')) {
            for (final part in selector.split('#')) {
              getSelector(part);
            }
            return false;
          }
        }
      } while (s != selector);
      if (RegExp(r',[mwd0](&[ol\d+])?,w|,[hfs1](&[ol\d]+)?,h')
          .hasMatch(selector)) {
        return false;
      }
      result.add(selector);
    }
    return true;
  }

  getSelector(selector);
  return result;
}

/// 选择器转ID
List<String> selector2id(String selector, [int sex = -1]) {
  if (!RegExp(r'^,').hasMatch(selector)) {
    selector = ',$selector';
  }
  // 性别判断
  if (sex < 0) {
    if (RegExp(r'^,[w1]').hasMatch(selector)) {
      sex = 1;
    } else if (RegExp(r'^,[h0]').hasMatch(selector)) {
      sex = 0;
    }
  } else if (sex == 1 && RegExp(r'^,[h0]').hasMatch(selector)) {
    return [];
  } else if (sex == 0 && RegExp(r'^,[w1]').hasMatch(selector)) {
    return [];
  }
  if (sex > -1 && !selector.contains(',1') && !selector.contains(',0')) {
    selector = ',$sex$selector';
  }
  if (RegExp(r',[mwd0](&[ol\d]+)?,w|,[hfs1](&[ol\d]+)?,h')
      .hasMatch(selector)) {
    return [];
  }
  final result = expandSelector(selector)
      .map((s) => s.replaceFirst(RegExp(r',[01]'), '').substring(1))
      .toList();
  return filterId(result);
}
