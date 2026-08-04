import 'package:gif_view/gif_view.dart';

/// A wrapper around [GifController] that prevents "used after being disposed"
/// errors by ignoring [notifyListeners] calls after the controller is disposed.
class SafeGifController extends GifController {
  bool _disposed = false;

  SafeGifController({
    super.autoPlay = true,
    super.loop = true,
    super.inverted = false,
    super.onStart,
    super.onFinish,
    super.onFrame,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
