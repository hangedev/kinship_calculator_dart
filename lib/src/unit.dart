// 数值转换

const List<String> _textAttr = [
  '',
  '一',
  '二',
  '三',
  '四',
  '五',
  '六',
  '七',
  '八',
  '九',
  '十',
];

/// 中文数字转阿拉伯数字
int zh2number(String text) {
  const map = {'大': 1, '小': 99};
  if (map.containsKey(text)) {
    return map[text]!;
  }
  final parts =
      text.replaceAll(RegExp(r'^十'), '一十').split('十');
  final mapped =
      parts.map((word) => _textAttr.indexOf(word)).toList();
  final reversed = mapped.reversed.toList();
  final unit = reversed[0];
  final dec = reversed.length > 1 ? reversed[1] : 0;
  return dec * 10 + unit;
}

/// 阿拉伯数字转中文数字
String number2zh(int num) {
  const map = {1: '大', 99: '小'};
  if (map.containsKey(num)) {
    return map[num]!;
  }
  final dec = num ~/ 10;
  final unit = num % 10;
  final decStr =
      dec > 0 ? '${_textAttr[dec]}十'.replaceAll('一十', '十') : '';
  return '$decStr${_textAttr[unit]}';
}

/// Build replacement function from a JS-style replacement string with $1, $2, etc.
String Function(Match) _buildReplacer(String replacement) {
  return (Match m) {
    String result = replacement;
    // Replace $0..$9 backreferences (process higher numbers first)
    for (int i = m.groupCount; i >= 0; i--) {
      result = result.replaceAll('\$$i', m.group(i) ?? '');
    }
    return result;
  };
}

/// replaceAll with backreference support (like JS String.replace with /g flag)
String regReplace(String input, RegExp pattern, String replacement) {
  if (!replacement.contains(r'$')) {
    return input.replaceAll(pattern, replacement);
  }
  return input.replaceAllMapped(pattern, _buildReplacer(replacement));
}

/// replaceFirst with backreference support (like JS String.replace without /g)
String regReplaceFirst(String input, RegExp pattern, String replacement) {
  if (!replacement.contains(r'$')) {
    return input.replaceFirst(pattern, replacement);
  }
  return input.replaceFirstMapped(pattern, _buildReplacer(replacement));
}
