import 'package:firebase_database/firebase_database.dart';
import 'admin_config_model.dart';

class ConfigRepository {
  final DatabaseReference _dbRef;

  ConfigRepository({FirebaseDatabase? database})
    : _dbRef = (database ?? FirebaseDatabase.instance).ref().child(
        'admin_settings/support_section',
      );

  Stream<AdminConfigModel> getConfigStream() {
    return _dbRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value != null && value is Map) {
        return AdminConfigModel.fromMap(value);
      }
      return AdminConfigModel.initial();
    });
  }

  Future<void> updateConfig(AdminConfigModel config) async {
    await _dbRef.update(config.toMap());
  }
}
