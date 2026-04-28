import 'dart:js_interop';

/// Định nghĩa class giao tiếp JS theo phong cách cũ (Dart 2.19)
@JS('PdfiumWasmCommunicator')
class _PdfiumWasmCommunicator {
  external _PdfiumWasmCommunicator();

  /// Gửi command và nhận về một JS Promise
  /// Trong Dart 2.19, chúng ta dùng Object đại diện cho Promise và js_util để handle
  @JS('sendCommand')
  external Object sendCommand([String? command, Object? parameters, List<Object>? transfer]);

  @JS('registerCallback')
  external int registerCallback(Function callback);

  @JS('unregisterCallback')
  external void unregisterCallback(int callbackId);
}

// Vì không có extension type, các đoạn code gọi communicator.sendCommand(...) 
// có thể cần dùng js_util.promiseToFuture(communicator.sendCommand(...))
