class UserManager {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String? userName;

  void setUserName(String name) {
    userName = name;
  }
}
