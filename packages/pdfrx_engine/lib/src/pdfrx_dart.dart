import 'package:image/image.dart';

import 'pdf_image.dart';

extension PdfImageDartExt on PdfImage {
  /// Create [Image] (of [image package](https://pub.dev/packages/image)) from the rendered image.
  ///
  /// [pixelSizeThreshold] specifies the maximum allowed pixel size (width or height).
  /// If the image exceeds this size, it will be downscaled to fit within the threshold
  /// while maintaining the aspect ratio.
  /// [interpolation] specifies the interpolation method to use when resizing images.
  ///
  /// **NF**: This method does not require Flutter and can be used in pure Dart applications.
  Image createImageNF({int? pixelSizeThreshold, Interpolation interpolation = Interpolation.linear}) {
    // Với phiên bản image cũ (3.x), Image.fromBytes nhận Uint8List và channels là enum Channels.rgba
    // Dữ liệu từ PDFium thường là BGRA, chúng ta cần đảm bảo convert đúng nếu bản cũ không hỗ trợ ChannelOrder
    final image = Image.fromBytes(
      width,
      height,
      pixels.buffer.asUint8List(),
      format: Format.rgba, // Hoặc dùng Channels.rgba tùy version cụ thể bạn đang hạ xuống
    );

    if (pixelSizeThreshold != null && (width > pixelSizeThreshold || height > pixelSizeThreshold)) {
      final aspectRatio = width / height;
      int targetWidth;
      int targetHeight;
      if (width >= height) {
        targetWidth = pixelSizeThreshold;
        targetHeight = (pixelSizeThreshold / aspectRatio).round();
      } else {
        targetHeight = pixelSizeThreshold;
        targetWidth = (pixelSizeThreshold * aspectRatio).round();
      }
      return copyResize(image, width: targetWidth, height: targetHeight, interpolation: interpolation);
    }
    return image;
  }
}

extension ImagePdfExt on Image {
  /// Create [PdfImage] from [Image] (of [image package](https://pub.dev/packages/image)).
  ///
  /// - [order] specifies the channel order of the resulting image data.
  /// - If [bgraConversionInPlace] is set to true and conversion is needed, the conversion will be done in place
  ///   modifying the original image data. This can save memory but will alter the original image.
  PdfImage toPdfImageNF({bool bgraConversionInPlace = false}) {
    // Trong bản cũ, data là Uint8List trực tiếp, không phải đối tượng Data
    return PdfImage.createFromBgraData(
      getBytes(), // Trả về Uint8List trong bản cũ
      width: width,
      height: height,
    );
  }
}
