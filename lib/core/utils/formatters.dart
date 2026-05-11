// NutriPump — Shared utility functions
// Equivalent to /src/lib/utils/index.ts

/// Format a number as Indian Rupee price
/// e.g. 1234.5 → "₹1,234"
String formatPrice(double amount) {
  final rounded = amount.round();
  final str = rounded.toString();
  if (str.length <= 3) return '₹$str';

  final buffer = StringBuffer();
  final chars = str.split('');
  final len = chars.length;

  for (int i = 0; i < len; i++) {
    if (i == len - 3 && i != 0) {
      buffer.write(',');
    } else if (i > 0 && (len - i) % 2 == 1 && i < len - 3) {
      buffer.write(',');
    }
    buffer.write(chars[i]);
  }
  return '₹$buffer';
}

/// Calculate discount percentage
int calculateDiscount(double compareAt, double price) {
  if (compareAt <= price) return 0;
  return (((compareAt - price) / compareAt) * 100).round();
}

/// Convert a string to URL-safe slug
String slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'[\s_-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

/// Truncate text to n characters with ellipsis
String truncate(String text, int length) {
  if (text.length <= length) return text;
  return '${text.substring(0, length)}...';
}

/// Format date as "Apr 23, 2026"
String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Format date with time: "Apr 23, 2026 at 11:30 AM"
String formatDateTime(DateTime date) {
  final hour = date.hour > 12
      ? date.hour - 12
      : date.hour == 0
          ? 12
          : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${formatDate(date)} at $hour:$minute $period';
}

/// Format relative time: "2 hours ago", "Just now"
String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(date);
}

/// Format an order ID with NP- prefix — consistent across all screens.
/// Admin panel shows the last 8 chars of the Firestore document ID (e.g. #J35KVTVX).
/// Mobile shows the same suffix with NP- prefix: NP-J35KVTVX.
String formatOrderId(String id) {
  final suffix = id.length > 8 ? id.substring(id.length - 8) : id;
  return 'NP-${suffix.toUpperCase()}';
}
