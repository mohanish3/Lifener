//Utility class that implements simple time functions
class TimeFunctions {
  static Map<String, int> subtractTime(int aH, int aM, int bH, int bM) {
    int resHours;
    int resMinutes;
    resMinutes = aH * 60 + aM - bH * 60 - bM;
    if (resMinutes >= 0) {
      resHours = (resMinutes / 60).floor();
      resMinutes = resMinutes % 60;
    } else {
      resHours = -((-resMinutes / 60).floor());
      resMinutes = -(-resMinutes % 60);
    }

    return {'hours': resHours, 'minutes': resMinutes};
  }

  static Map<String, dynamic> addTime(int aH, int aM, int bH, int bM) {
    int resMinutes = (aH * 60 + aM + bH * 60 + bM) % 60;
    int resHours = ((aH * 60 + aM + bH * 60 + bM) / 60).floor();
    return {'hours': resHours, 'minutes': resMinutes};
  }

}
