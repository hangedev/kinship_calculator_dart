import 'data/filter.dart';
import 'kinship_option.dart';
import 'data/main.dart';

/// [KinshipCalculator]
/// Kinship Calculator 亲戚计算器
class KinshipCalculator {
  static const String _keyRegexp = 'exp';
  static const String _keyString = 'str';

  /// 数组去重
  static List<String> _unique(List<String> array) {
    var result = <String>[];
    var hash = <String, bool>{};
    String item;
    for (var i = 0; i < array.length; i++) {
      item = array[i];

      /// 对特殊语法标识相互包含的行为去重
      var temp = item
          .replaceFirst(RegExp('[ol](?=s|b)'), 'x')
          .replaceFirst(RegExp('&[ol]'), '');
      if ((hash[item] == null || !hash[item]!) &&
          (hash[temp] == null || !hash[temp]!)) {
        result.add(item);
        hash[item] = true;
      }
    }
    return result;
  }

  /// 分词解析
  static List<String> _getSelectors(String str) {
    str = str.replaceAll(RegExp('[二|三|四|五|六|七|八|九|十]{1,2}'), 'x');
    var words = str
        .replaceFirst('我', '')
        .replaceFirst('家的', '的')
        .replaceFirst('家', '的')
        .split('的');

    /// 所有可能性
    var result = <String>[];
    var match = true;
    while (words.isNotEmpty) {
      /// 当前匹配词
      var name = words.removeAt(0);

      ///当前匹配词可能性
      var arr = <String>[];
      var has = false;
      mainData.forEach((key, value) {
        /// 是否存在该关系
        if (value.contains(name)) {
          /// 对‘我’的优化
          if (key.isNotEmpty || words.isEmpty) {
            arr.add(key);
          }
          has = true;
        }
      });
      if (!has) {
        match = false;
      }

      /// 当前匹配词与之前可能性组合
      if (result.isNotEmpty) {
        var res = <String>[];
        for (var e1 in result) {
          for (var e2 in arr) {
            res.add('$e1,$e2');
          }
        }
        result = res;
      } else {
        for (var e in arr) {
          result.add(',$e');
        }
      }
    }
    return match ? result : <String>[];
  }

  /// 简化选择器
  static List<String> _selector2id(String selector, int sex) {
    var result = <String>[];
    var hash = <String, bool>{};

    /// 如果自己的性别不确定
    if (sex < 0) {
      if (selector.indexOf(',w') == 0) {
        sex = 1;
      } else if (selector.indexOf(',h') == 0) {
        sex = 0;
      }
    }

    if (sex > -1) {
      selector = ',$sex$selector';
    }

    /// 同志关系去除
    if (RegExp(',[w0],w|,[h1],h').allMatches(selector).isNotEmpty) {
      return <String>[];
    }

    dynamic getId(String selector) {
      var s = '';
      if (hash[selector] == null || !hash[selector]!) {
        hash[selector] = true;
        var status = true;
        do {
          s = selector;
          for (var i = 0; i < filterData.length; i++) {
            var filterItem = filterData[i];
            if (filterItem[_keyRegexp].endsWith('/g')) {
              var pattern = RegExp(filterItem[_keyRegexp].replaceAll('/g', ''));
              selector =
                  selector.replaceAllMapped(pattern, filterItem[_keyString]);
            } else {
              var pattern = RegExp(filterItem[_keyRegexp]);
              selector =
                  selector.replaceFirstMapped(pattern, filterItem[_keyString]);
            }
            if (selector.contains('#')) {
              var arr = selector.split('#');
              for (var e in arr) {
                if (e.isNotEmpty) {
                  getId(e);
                }
              }
              status = false;
              break;
            }
          }
        } while (s != selector);
        if (status) {
          /// 同志关系去除
          if (RegExp(',[w0],w|,[h1],h').allMatches(selector).isNotEmpty) {
            return false;
          }

          /// 去前面逗号和性别信息
          if (selector
              .replaceFirstMapped(RegExp(',[01]'), (match) => '')
              .isNotEmpty) {
            selector = selector
                .replaceFirstMapped(RegExp(',[01]'), (match) => '')
                .substring(1);
            result.add(selector);
          }
        }
      }
    }

    getId(selector);
    return _unique(result);
  }

  /// 获取数据
  static List<String> _getDataById(String id) {
    var items = <String>[];
    List<String> getData(String str) {
      var res = <String>[];
      mainData.forEach((key, value) {
        if (key.replaceAll(RegExp('&[olx]'), '') == str) {
          res.add(value[0]);
        }
      });
      return res;
    }

    /// 直接匹配称呼
    if (mainData.containsKey(id)) {
      items.add(mainData[id]![0]);
    } else {
      items = getData(id);

      /// 忽略年龄条件查找
      if (items.isEmpty) {
        id = id.replaceAll(RegExp('&[ol]'), '');
        items = getData(id);
      }

      /// 忽略年龄条件查找
      if (items.isEmpty) {
        id = id.replaceAll(RegExp('[ol]'), 'x');
        items = getData(id);
      }

      /// 缩小访问查找
      if (items.isEmpty) {
        var l = id.replaceAll(RegExp('x'), 'l');
        items = getData(l);
        var o = id.replaceAll(RegExp('x'), 'o');
        items.addAll([...getData(o)]);
      }
    }
    return items;
  }

  /// 逆转 ID
  static String _reverseId(String id, int sex) {
    var hash = <String, List<String>>{
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

    var age = '';
    if (id.contains('&o')) {
      age = '&l';
    } else if (id.contains('&l')) {
      age = '&o';
    }

    if (id.isNotEmpty) {
      id = id.replaceAll(RegExp('&[ol]'), '');

      /// 逆转运算自身性别必须确定
      sex = (sex != 0) ? 1 : 0;
      var sid = (',$sex,$id')
          .replaceAll(RegExp(',[fhs]|,[olx]b'), ',1')
          .replaceAll(RegExp(',[mwd]|,[olx]s'), ',0');
      sid = sid.substring(0, sid.lastIndexOf(','));
      var idList = id.split(',').reversed.toList();
      var sidList = <int>[];
      sid.split(',').reversed.toList().forEach((e) {
        if (e.isNotEmpty) {
          sidList.add(int.parse(e));
        }
      });
      var arr = <String>[];
      for (var i = 0; i < idList.length; i++) {
        arr.add(hash[idList[i]]![sidList[i]]);
      }
      return arr.join(',') + age;
    }
    return '';
  }

  ///获取关系链条
  static String _getChainById(String id) {
    var arr = id.split(',');
    var items = <String>[];
    for (var i = 0; i < arr.length; i++) {
      var key = arr[i].replaceFirst(RegExp('&[ol]'), '');
      if (key.isNotEmpty &&
          mainData.containsKey(key) &&
          mainData[key]!.isNotEmpty) {
        items.add(mainData[key]![0]);
      }
    }
    return items.join('的');
  }

  /// 计算
  static List<String> calculate(KinshipOption option) {
    var text = option.text;
    var sex = option.sex;
    var type = option.type;
    var reverse = option.reverse;

    /// 'type' 为 'chain' 时, 'reverse' 无效

    var selectors = _getSelectors(text);
    var result = <String>[];

    ///匹配结果
    for (var selector in selectors) {
      ///遍历所有可能性
      var ids = _selector2id(selector, sex);
      for (var id in ids) {
        if (type == 'chain') {
          var item = _getChainById(id);
          if (item.isNotEmpty) {
            result.add(item);
          }
        } else {
          if (reverse) {
            id = _reverseId(id, sex);
          }
          var items = _getDataById(id);
          if (items.isNotEmpty) {
            result.addAll(items);
          } else if (id.indexOf('w') == 0 || id.indexOf('h') == 0) {
            ///找不到关系，随爱人叫
            items = _getDataById(id.substring(2));
            if (items.isNotEmpty) {
              result.addAll(items);
            }
          }
        }
      }
    }
    return _unique(result);
  }
}
