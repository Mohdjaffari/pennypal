import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Renders receipt images robustly across Web, Android, iOS, Windows, macOS:
/// supports raw base64 data, data URLs, network URLs, and local file paths.
class ReceiptImageViewer extends StatelessWidget {
  final String receiptPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ReceiptImageViewer({
    super.key,
    required this.receiptPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  /// Opens an interactive, full-screen zoomed preview of the receipt.
  static void showPreview(BuildContext context, String receiptPath, {String? title}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title ?? 'Receipt Preview',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Interactive Zoomable Image Card
              Flexible(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: ReceiptImageViewer(
                        receiptPath: receiptPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pinch or drag to zoom and pan receipt',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipRadius = borderRadius ?? BorderRadius.circular(12);

    Widget imageWidget;
    if (receiptPath.startsWith('http://') || receiptPath.startsWith('https://')) {
      imageWidget = Image.network(
        receiptPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildFallback(context),
      );
    } else if (receiptPath.startsWith('data:image') || _isLikelyBase64(receiptPath)) {
      try {
        final pureBase64 = receiptPath.contains(',')
            ? receiptPath.split(',').last
            : receiptPath;
        final bytes = base64Decode(pureBase64);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildFallback(context),
        );
      } catch (e) {
        imageWidget = _buildFallback(context);
      }
    } else if (!kIsWeb) {
      final file = File(receiptPath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildFallback(context),
        );
      } else {
        imageWidget = _buildFallback(context);
      }
    } else {
      imageWidget = _buildFallback(context);
    }

    return ClipRRect(
      borderRadius: clipRadius,
      child: imageWidget,
    );
  }

  bool _isLikelyBase64(String str) {
    if (str.length < 20) return false;
    final clean = str.trim();
    return !clean.contains(' ') && (clean.length % 4 == 0 || clean.contains('base64'));
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width ?? 80,
      height: height ?? 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryBlue.withValues(alpha: 0.7),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Receipt',
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
