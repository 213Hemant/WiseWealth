import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  // Creating an instance of LocalAuthentication
  final LocalAuthentication _localAuth = LocalAuthentication();

  // This function checks if biometric authentication is available
  Future<bool> canCheckBiometrics() async {
    try {
      // Check if biometric sensors are available on the device
      bool canCheck = await _localAuth.canCheckBiometrics;
      return canCheck;
    } catch (e) {
      print("Error checking biometrics: $e");
      return false; // Return false if an error occurs
    }
  }

  // This function requests biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      // Check if biometric authentication is available
      bool canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        // If biometrics are not available or not set up
        print("Biometrics not available or set up.");
        return false;
      }

      // Trigger the biometric authentication
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the Goals tab',
        options: AuthenticationOptions(
          useErrorDialogs: true, // Show system error dialogs if needed
          stickyAuth: true, // Keep the authentication dialog open until successful
        ),
      );

      return authenticated; // Return true if authentication is successful
    } catch (e) {
      print('Error in biometric authentication: $e');
      return false; // Return false if authentication fails
    }
  }
}
