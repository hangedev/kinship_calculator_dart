# KinshipCalculator

[![pub package](https://img.shields.io/pub/v/kinship_calculator.svg)](https://pub.dev/packages/kinship_calculator)
[![GitHub license](https://img.shields.io/github/license/yeliulee/kinship_calculator_dart)](https://github.com/yeliulee/kinship_calculator_dart/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/yeliulee/kinship_calculator_dart?logo=github&style=flat)](https://github.com/yeliulee/kinship_calculator_dart/stargazers)

Chinese kinship/relationship calculator.

中国亲戚关系计算器

## Features

- 通过关系链计算称谓 (Calculate terms from relationship descriptions)
- 通过称谓计算关系链 (Calculate relationship chain from terms)
- 逆向查找称呼 (Reverse relationship lookup)
- 支持相对对象 (Support relative target, e.g., how A calls B)
- 关系合称 (Relationship pair names, e.g., 父子、夫妻)
- 性别设置 (Gender specification)
- 年龄/排行 (Age/ranking support, e.g., 二舅、大伯)
- 最短关系计算 (Shortest relationship path)
- 自然语言表达 (Natural language expression parsing)
- 地区模式 (Regional mode support)

## Getting started

Add `kinship_calculator` to your pubspec.yaml:

```yaml
dependencies:
  kinship_calculator: ^4.0.0
```

Then run `dart pub get` or `flutter pub get`.

## Usage

```dart
import 'package:kinship_calculator/kinship_calculator.dart';

void main() {
  // 如：我应该叫外婆的哥哥什么？
  print(relationship(text: '妈妈的妈妈的哥哥'));
  // => [舅外公]

  // 如：七舅姥爷应该叫我什么？
  print(relationship(text: '七舅姥爷', reverse: true, sex: 1));
  // => [甥外孙]

  // 如：舅公是什么亲戚
  print(relationship(text: '舅公', type: 'chain'));
  // => [爸爸的妈妈的兄弟, 妈妈的妈妈的兄弟, 老公的妈妈的兄弟]

  // 如：舅妈如何称呼外婆？
  print(relationship(text: '外婆', target: '舅妈', sex: 1));
  // => [婆婆]

  // 如：外婆和奶奶之间是什么关系？
  print(relationship(text: '外婆', target: '奶奶', type: 'pair'));
  // => [儿女亲家]

  // 自然语言表达
  print(relationshipFromExpression('舅妈如何称呼外婆？'));
  // => [婆婆]

  print(relationshipFromExpression('外婆和奶奶之间是什么关系？'));
  // => [儿女亲家]
}
```

### API

#### `relationship()`

主要的计算方法。

```dart
List<String> relationship({
  required String text,    // 目标对象的称谓汉字表达，称谓间用'的'字分隔
  String target = '',      // 相对对象的称谓，空表示自己
  int sex = -1,            // 本人性别：0女性, 1男性, -1未知
  String type = 'default', // 转换类型：'default'计算称谓, 'chain'计算关系链, 'pair'计算关系合称
  bool reverse = false,    // 称呼方式：true对方称呼我, false我称呼对方
  String mode = 'default', // 模式选择
  bool optimal = false,    // 最短关系
});
```

#### `relationshipFromExpression()`

通过自然语言表达式计算关系。

```dart
List<String> relationshipFromExpression(String expression);
```

支持的句式：`xxx是xxx的什么人`、`xxx叫xxx什么`、`xxx如何称呼xxx`、`xxx和xxx之间是什么关系` 等。

#### `setRelationshipMode()`

注册自定义地区模式。

```dart
void setRelationshipMode(String name, Map<String, List<String>> data);
```

用法示例：

```dart
// 关系解析语法
// 【关系链】f:父,m:母,h:夫,w:妻,s:子,d:女,xb:兄弟,ob:兄,lb:弟,xs:姐妹,os:姐,ls:妹
// 【修饰符】 1:男性,0:女性,&o:年长,&l:年幼,#:隔断,[a|b]:并列
setRelationshipMode('northern', {
  'm,f': ['姥爷'],
  'm,m': ['姥姥'],
  'm,xb,s&o': ['表哥'],
  'm,xb,s&l': ['表弟'],
});

// 使用自定义模式
relationship(text: '妈妈的妈妈', mode: 'northern');
```

For more examples, see the `example` folder.

## Thanks

Ported from [mumuy/relationship](https://github.com/mumuy/relationship).

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/yeliulee/kinship_calculator_dart/issues).
