import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repository/pennypal_repository.dart';

/// Clean, non-intrusive status pill displaying SQLite offline state
/// or active Firebase Cloud Firestore synchronization.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PennyPalRepository.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: repo.isOnlineNotifier,
      builder: (context, isOnline, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: repo.isSyncingNotifier,
          builder: (context, isSyncing, _) {
            if (isOnline && !isSyncing) {
              return const SizedBox.shrink();
            }

            final isOffline = !isOnline;
            final bgColor = isOffline
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFEEF2FF);
            final textColor = isOffline
                ? const Color(0xFF92400E)
                : AppColors.primaryBlue;
            final icon = isOffline
                ? Icons.cloud_off_rounded
                : Icons.sync_rounded;
            final message = isOffline
                ? 'Offline • Saved to SQLite'
                : 'Syncing with Firebase...';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOffline
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFC7D2FE),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSyncing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBlue,
                      ),
                    )
                  else
                    Icon(icon, size: 16, color: textColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isOffline)
                    InkWell(
                      onTap: () => repo.syncNow(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
