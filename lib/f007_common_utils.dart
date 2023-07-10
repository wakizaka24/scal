import 'package:flutter_emoji/flutter_emoji.dart';

class CommonUtils {
  static final CommonUtils _instance = CommonUtils._internal();
  CommonUtils._internal();

  factory CommonUtils() {
    return _instance;
  }

  String replaceUnsupportedCharacters(String str) {
    var parser = EmojiParser();
    return parser.unemojify(str);
  }
}