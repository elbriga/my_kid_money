import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate(String msg) async {
    return true; // Para funcionar no emulador
    try {
      final ok = await _auth.authenticate(
        localizedReason: msg,
        biometricOnly: true,
        //stickyAuth: true,
      );
      return ok;
    } catch (_) {
      return false;
    }
  }
}
