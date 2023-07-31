class CommonUtils {
  static final CommonUtils _instance = CommonUtils._internal();
  CommonUtils._internal();

  factory CommonUtils() {
    return _instance;
  }
}