import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../providers/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.h3(context)),
        centerTitle: true,
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.done_all, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
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
              padding: EdgeInsets.only(top: R.h(context, 16), bottom: R.h(context, 32)),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 6)),
                  child: Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(R.w(context, 16)),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: R.w(context, 24)),
                      child: Icon(Icons.delete_outline, color: Colors.white, size: R.sp(context, 28)),
                    ),
                    onDismissed: (_) {
                      ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
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
                          padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 14)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIconOrImage(context, notification.imageUrl, notification.isRead),
                              SizedBox(width: R.w(context, 12)),
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
                                              color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                        if (!notification.isRead)
                                          Container(
                                            margin: EdgeInsets.only(left: R.w(context, 8), top: R.h(context, 2)),
                                            width: R.w(context, 6),
                                            height: R.w(context, 6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: R.h(context, 4)),
                                    Text(
                                      notification.body,
                                      style: AppTypography.caption(context).copyWith(
                                        color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.7),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: R.h(context, 8)),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time, 
                                          size: R.sp(context, 12), 
                                          color: AppColors.neutralGold.withValues(alpha: 0.8),
                                        ),
                                        SizedBox(width: R.w(context, 4)),
                                        Text(
                                          timeago.format(notification.timestamp),
                                          style: AppTypography.caption(context).copyWith(
                                            color: AppColors.neutralGold.withValues(alpha: 0.8),
                                            fontSize: R.sp(context, 11),
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

  Widget _buildIconOrImage(BuildContext context, String? imageUrl, bool isRead) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: R.w(context, 48),
        height: R.w(context, 48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.w(context, 10)),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.w(context, 9)),
          child: CustomNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: R.w(context, 48),
      height: R.w(context, 48),
      decoration: BoxDecoration(
        color: isRead ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight) : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.w(context, 10)),
        border: Border.all(
          color: isRead ? AppColors.borderLight : AppColors.primary.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: isRead ? AppColors.neutralGold.withValues(alpha: 0.5) : AppColors.primary,
        size: R.sp(context, 20),
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
            size: R.sp(context, 80),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: R.h(context, 16)),
          Text(
            'No notifications yet',
            style: AppTypography.h3(context).copyWith(color: AppColors.neutralGold),
          ),
          SizedBox(height: R.h(context, 8)),
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
