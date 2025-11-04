import '../services/localstorage.dart';

class PhoneServices {
  static const String _key = 'phones';

  static Future<List<Map<String, dynamic>>> getPhones() async {
    final data = await LocalStorage.getData(_key);
    if (data == null) return [];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> addPhone(Map<String, dynamic> phone) async {
     await Future.delayed(const Duration(seconds: 2));
    final phones = await getPhones();
    phones.add(phone);
    await LocalStorage.saveData(_key, phones);
  }

  static Future<void> deletePhone(Map<String, dynamic> phone) async {
     await Future.delayed(const Duration(seconds: 2));
    final phones = await getPhones();
    phones.removeWhere((p) => p['name'] == phone['name']);
    await LocalStorage.saveData(_key, phones);
  }

  static Future<void> updatePhone(
      Map<String, dynamic> oldPhone, Map<String, dynamic> updatedPhone) async {
         await Future.delayed(const Duration(seconds: 2));
    final phones = await getPhones();
    final index = phones.indexWhere((p) => p['name'] == oldPhone['name']);
    if (index != -1) {
      phones[index] = updatedPhone;
      await LocalStorage.saveData(_key, phones);
    }
  }
}
