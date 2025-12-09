import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  static LoadingController get to => Get.find();
  
  final _loadingStates = <String, bool>{}.obs;
  final _loadingMessages = <String, String>{}.obs;
  
  bool isLoading(String key) => _loadingStates[key] ?? false;
  String getLoadingMessage(String key) => _loadingMessages[key] ?? 'Cargando...';
  
  void setLoading(String key, {bool loading = true, String message = 'Cargando...'}) {
    _loadingStates[key] = loading;
    if (loading) {
      _loadingMessages[key] = message;
    } else {
      _loadingMessages.remove(key);
    }
  }
  
  void clearLoading(String key) {
    _loadingStates.remove(key);
    _loadingMessages.remove(key);
  }
  
  void clearAllLoading() {
    _loadingStates.clear();
    _loadingMessages.clear();
  }
}

class LoadingWrapper extends StatelessWidget {
  final String loadingKey;
  final Widget child;
  final Widget? loadingWidget;
  final Color? loadingColor;
  
  const LoadingWrapper({
    Key? key,
    required this.loadingKey,
    required this.child,
    this.loadingWidget,
    this.loadingColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = LoadingController.to;
      final isLoading = controller.isLoading(loadingKey);
      
      return Stack(
        children: [
          child,
          if (isLoading)
            Container(
              color: (loadingColor ?? Colors.black).withOpacity(0.3),
              child: Center(
                child: loadingWidget ?? 
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            controller.getLoadingMessage(loadingKey),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
        ],
      );
    });
  }
}

class LoadingButton extends StatelessWidget {
  final String loadingKey;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool disabled;
  
  const LoadingButton({
    Key? key,
    required this.loadingKey,
    required this.onPressed,
    required this.child,
    this.style,
    this.disabled = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = LoadingController.to.isLoading(loadingKey);
      final isDisabled = disabled || isLoading;
      
      return ElevatedButton(
        style: style,
        onPressed: isDisabled ? null : onPressed,
        child: isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
      );
    });
  }
}
