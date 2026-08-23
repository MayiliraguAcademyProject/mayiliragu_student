import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/toast_helper.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = 'Document Viewer',
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  @override
  void dispose() {
    // Clean up temporary cache file
    if (_localFilePath != null) {
      try {
        final file = File(_localFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        Get.log('Error deleting temp PDF file: $e');
      }
    }
    super.dispose();
  }

  String _resolveFullUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = AppConfig.baseUrl.replaceAll('/api', '');
    return '$base$trimmed';
  }

  Future<void> _downloadAndLoadPdf() async {
    if (widget.pdfUrl.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or empty PDF link.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fullUrl = _resolveFullUrl(widget.pdfUrl);
      final uri = Uri.parse(fullUrl);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName = 'temp_doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${dir.path}/$fileName');

        await file.writeAsBytes(bytes, flush: true);

        if (mounted) {
          setState(() {
            _localFilePath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load PDF (Error: ${response.statusCode})';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to download PDF. Please check your internet connection.';
        });
      }
    }
  }

  Future<void> _promptAndSavePdfToStorage() async {
    if (_localFilePath == null) {
      AppToast.error('PDF document is not ready to download.');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ask the student where they want to store the PDF:
    // 'DOWNLOADS' -> default downloads folder
    // 'CUSTOM' -> prompt file picker to choose custom folder / SD Card
    // null -> canceled
    final String? chosenLocation = await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Download Document',
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose storage location for "${widget.title}":',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Option 1: Standard Downloads Folder
              InkWell(
                onTap: () => Get.back(result: 'DOWNLOADS'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save to Downloads',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Standard phone Downloads folder',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Custom Directory / SD Card Picker
              InkWell(
                onTap: () => Get.back(result: 'CUSTOM'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.create_new_folder_outlined, color: Colors.amber, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Custom Folder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Select specific folder or SD Card',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              TextButton(
                onPressed: () => Get.back(result: null),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white60 : Colors.black54,
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );

    if (chosenLocation == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final safeName = widget.title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .trim();
      final fileName = safeName.endsWith('.pdf') ? safeName : '$safeName.pdf';

      String? targetDirectoryPath;

      if (chosenLocation == 'CUSTOM') {
        // Open system folder picker so student can pick exact location
        targetDirectoryPath = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select folder to save "$fileName"',
        );

        if (targetDirectoryPath == null) {
          // Student canceled directory picker
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } else {
        // Standard Downloads folder
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            targetDirectoryPath = downloadDir.path;
          }
        }
        targetDirectoryPath ??= (await getDownloadsDirectory())?.path;
        targetDirectoryPath ??= (await getApplicationDocumentsDirectory()).path;
      }

      final destinationPath = '$targetDirectoryPath/$fileName';
      final sourceFile = File(_localFilePath!);
      await sourceFile.copy(destinationPath);

      if (chosenLocation == 'CUSTOM') {
        AppToast.success('PDF saved to selected folder!');
      } else {
        AppToast.success('Document saved to your Downloads folder!');
      }
    } catch (e) {
      Get.log('Error saving PDF to storage: $e');
      AppToast.error('Could not save PDF file to storage.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppTextStyles.subheading.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null && _totalPages > 0)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (!_isLoading && _errorMessage == null && _localFilePath != null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Icon(Icons.file_download_outlined, size: 22),
              tooltip: 'Download to Storage',
              color: isDark ? Colors.white : Colors.black87,
              onPressed: _isSaving ? null : _promptAndSavePdfToStorage,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading PDF document...',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _localFilePath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Open PDF',
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An error occurred while loading the document.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _downloadAndLoadPdf,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localFilePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = error.toString();
            });
          },
          onPageError: (page, error) {
            setState(() {
              _errorMessage = 'Page $page error: $error';
            });
          },
          onPageChanged: (int? page, int? total) {
            if (page != null) {
              setState(() {
                _currentPage = page;
              });
            }
          },
        ),
      ],
    );
  }
}
