import 'package:get/get.dart';

/// Base class for all GetConnect providers.
/// Sets a global 15-second timeout so no request can hang the UI indefinitely.
class BaseProvider extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    httpClient.timeout = const Duration(seconds: 15);
  }
}
