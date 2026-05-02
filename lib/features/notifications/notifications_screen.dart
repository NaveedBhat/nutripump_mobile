import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../providers/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.h3(context)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.deepCharcoal),
              tooltip: 'Mark all as read',
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    onDismissed: (_) {
                      ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: notification.isRead ? AppColors.borderLight.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: notification.isRead 
                                ? Colors.black.withValues(alpha: 0.02) 
                                : AppColors.shadowGold.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          if (!notification.isRead) {
                            ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                          }
                          if (notification.route != null && notification.route!.isNotEmpty) {
                            context.push(notification.route!);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIconOrImage(notification.imageUrl, notification.isRead),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification.title,
                                            style: AppTypography.bodySM(context).copyWith(
                                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                              color: AppColors.deepCharcoal,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                        if (!notification.isRead)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8, top: 2),
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.body,
                                      style: AppTypography.caption(context).copyWith(
                                        color: AppColors.deepCharcoal.withValues(alpha: 0.7),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time, 
                                          size: 12, 
                                          color: AppColors.neutralGold.withValues(alpha: 0.8),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeago.format(notification.timestamp),
                                          style: AppTypography.caption(context).copyWith(
                                            color: AppColors.neutralGold.withValues(alpha: 0.8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildIconOrImage(String? imageUrl, bool isRead) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: CustomNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isRead ? AppColors.backgroundLight : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRead ? AppColors.borderLight : AppColors.primary.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: isRead ? AppColors.neutralGold.withValues(alpha: 0.5) : AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTypography.h3(context).copyWith(color: AppColors.neutralGold),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get updates or offers,\nthey\'ll show up here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
