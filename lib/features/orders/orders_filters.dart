/// Shared filter enums for the Orders feature.
library;

enum OrderStatusFilter { all, active, delivered, cancelled, paymentFailed }

enum OrderDateFilter { all, last30Days, last3Months, last6Months, thisYear }
