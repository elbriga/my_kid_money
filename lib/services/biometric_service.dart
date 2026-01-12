import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _disabled = 0;
  static final _timeout = 30000; // ms

  static final _auth = LocalAuthentication();
  static int _lastTSok = 0;

  static Future<bool> authenticate(String msg) async {
    if (_disabled == 1) return true; // Para funcionar no emulador

    if (_lastTSok > 0 &&
        (DateTime.now().millisecondsSinceEpoch - _lastTSok) < _timeout) {
      return true;
    }

    try {
      final ok = await _auth.authenticate(
        localizedReason: msg,
        biometricOnly: true,
      );
      if (ok) {
        _lastTSok = DateTime.now().millisecondsSinceEpoch;
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}
