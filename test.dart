import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared/shared.dart';

class PdfViewerScreen extends StatefulWidget {
  final String urlPdf;
  final String? title;
  final String? documentData;
  final bool fromAsset;
  final File? file;
  final Function(File)? onDocumentLoaded;

  const PdfViewerScreen(
      {super.key, this.title, required this.urlPdf, this.fromAsset = false, this.documentData, this.onDocumentLoaded, this.file});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool isLoading = false;
  String? document;
  final controller = PdfViewerController();
  TapDownDetails? _doubleTapDetails;

  Future<void> loadDocument(BuildContext context) async {
    try {
      CommonFunctions.showLoading(context);
      setState(() {
        isLoading = true;
      });
      if (widget.file != null || (widget.file?.path ?? '').isNotEmpty) {
        document = widget.file?.path;
        print("document pdf $document");
      } else {
        // Gửi request lấy file PDF
        if (widget.urlPdf.isEmpty) return;
        final response = await http.get(Uri.parse(widget.urlPdf), headers: {
          "Content-Type": "application/pdf",
        });

        if (response.statusCode == 200) {
          // Lưu file vào thư mục tạm
          final tempDir = await getTemporaryDirectory();
          final tempFilePath = '${tempDir.path}/temp_document.pdf';
          final file = File(tempFilePath);
          await file.writeAsBytes(response.bodyBytes);
          widget.onDocumentLoaded?.call(file);

          document = file.path;
          print("document pdf $document");
          print("Body bytes length: ${response.bodyBytes.length}");
          print("File saved at: $tempFilePath");
          print(utf8.decode(response.bodyBytes));
          print('File size: ${await file.length()} bytes');
        } else {
          print("Tải file thất bại: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Lỗi khi tải file: $e");
    } finally {
      CommonFunctions.hideLoading(context);
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!widget.fromAsset) loadDocument(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      key: widget.key,
      appBar: widget.title != null
          ? AppBar(
              centerTitle: true,
              title:
                  Text("${widget.title}", style: ThemeProvider.themeOf(context).data.extension<AppTextStyleTheme>()?.neut8Bold14),
              iconTheme: const IconThemeData(color: Colors.black),
              leading: CommonFunctions.buildBackButton(context),
              backgroundColor: ThemeProvider.themeOf(context).data.colorScheme.background,
              elevation: 0,
            )
          : null,
      body: Container(
        child: Stack(
          children: <Widget>[
            Stack(
              children: [
                (widget.fromAsset)
                    ? PdfViewer.asset(
                        widget.urlPdf,
                        controller: controller,
                        //onError: (err) => print(err),
                        params: PdfViewerParams(
                          margin: 10,
                          minScale: 1.0,
                          panAxis: PanAxis.vertical,
                          scaleEnabled: false,
                          // errorBannerBuilder: (context, error, stackTrace, documentRef) {
                          //   return const SizedBox.shrink();
                          // },

                          // scrollDirection: Axis.horizontal,
                        ),
                      )
                    : PdfViewer.uri(
                        Uri.parse(widget.urlPdf),
                        controller: controller,
                        //onError: (err) => print(err),
                        params: PdfViewerParams(
                          margin: 10,
                          minScale: 1.0,
                          // errorBannerBuilder: (context, error, stackTrace, documentRef) {
                          //   return const SizedBox.shrink();
                          // },

                          // scrollDirection: Axis.horizontal,
                        ),
                      ),
                // : (document != null)
                //     ? PdfViewer.uri(
                //         Uri.parse(widget.urlPdf),
                //         controller: controller,
                //         //onError: (err) => print(err),
                //         params: const PdfViewerParams(
                //           margin: 10,
                //           minScale: 1.0,

                //           // scrollDirection: Axis.horizontal,
                //         ),
                //       )
                //     : const SizedBox(),
                Positioned(
                  top: 15,
                  right: 15,
                  child: AnimatedBuilder(
                    // The controller is compatible with Listenable and you can receive notifications on scrolling and zooming of the view.
                    animation: controller,
                    builder: (context, child) => Container(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        child: Text(controller.isReady ? '${controller.pageNumber ?? 0}/${controller.pageCount}' : '-',
                            style: ThemeProvider.themeOf(context).data.extension<AppTextStyleTheme>()?.neut8Medi14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
