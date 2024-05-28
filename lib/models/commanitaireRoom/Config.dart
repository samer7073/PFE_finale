class Config {
  final int sortMessage;
  final int hiddenMessage;
  final int soundNotification;
  final int notification;
  final int? notificationMobile;
  final int? notificationMobileReaction;

  Config({
    required this.sortMessage,
    required this.hiddenMessage,
    required this.soundNotification,
    required this.notification,
    this.notificationMobile,
    this.notificationMobileReaction,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      sortMessage: _parseToInt(json['sort_message']),
      hiddenMessage: _parseToInt(json['hidden_message']),
      soundNotification: _parseToInt(json['sound_notification']),
      notification: _parseToInt(json['notification']),
      notificationMobile: json['notification_mobile'] != null
          ? _parseToInt(json['notification_mobile'])
          : null,
      notificationMobileReaction: json['notification_mobile_reaction'] != null
          ? _parseToInt(json['notification_mobile_reaction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sort_message': sortMessage,
      'hidden_message': hiddenMessage,
      'sound_notification': soundNotification,
      'notification': notification,
      'notification_mobile': notificationMobile,
      'notification_mobile_reaction': notificationMobileReaction,
    };
  }

  static int _parseToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }
}
