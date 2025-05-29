# KinshipCalculator

[![pub package](https://img.shields.io/pub/v/kinship_calculator.svg)](https://pub.dev/packages/kinship_calculator)
[![GitHub license](https://img.shields.io/github/license/yeliulee/kinship_calculator_dart)](https://github.com/yeliulee/kinship_calculator_dart/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/yeliulee/kinship_calculator_dart?logo=github&style=flat)](https://github.com/yeliulee/kinship_calculator_dart/stargazers)

Chinese kinship/relationship calculator.

中国亲戚关系计算器

## Features

- 性别设置
- 同种称呼的多种叫法
- 通过关系链计算称谓
- 通过称谓计算关系链
- 逆向查找称呼

## Getting started

add `kinship_calculator` to your pubspec.yaml

将依赖添加到项目的 pubspec.yaml

```yaml
dependencies:
  kinship_calculator: ^3.0.0
```

then run `pub get` or `flutter pub get` for flutter project

然后运行 `pub get`, flutter 项目运行 `flutter pub get`

## Usage

```dart
import 'package:kinship_calculator/kinship_calculator.dart';

void main() {
  final demo = KinshipCalculator.calculate(KinshipOption(
    text: '爸爸的弟弟',
  ));

  print('$demo');
}
```

For more example codes, please go to the `example` folder

更多的示例代码，请前往 example 文件夹

## Thanks

Ported from [mumuy/relationship][js_repo] with some modifications.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[js_repo]: https://github.com/mumuy/relationship
[tracker]: https://github.com/yeliulee/kinship_calculator_dart/issues
