import 'package:cloud_firestore/cloud_firestore.dart';

class RecentActivity {
  final String action;
  final String item;
  final DateTime timestamp;

  RecentActivity({
    required this.action,
    required this.item,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      action: json['action'],
      item: json['item'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'item': item,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
