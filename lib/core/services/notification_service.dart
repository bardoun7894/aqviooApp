import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for showing local notifications when content generation completes
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Cached locale for notifications
  String _currentLocale = 'ar';

  /// Update the locale for notifications (call when app locale changes)
  Future<void> updateLocale(String languageCode) async {
    _currentLocale = languageCode;
  }

  /// Load locale from shared preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLocale = prefs.getString('selected_locale') ?? 'ar';
    } catch (e) {
      debugPrint('Failed to load locale: $e');
    }
  }

  /// Get localized notification text
  Map<String, String> _getLocalizedStrings() {
    if (_currentLocale == 'ar') {
      return {
        'videoReadyTitle': 'الفيديو جاهز!',
        'videoReadyBody': 'تم إنشاء الفيديو بنجاح.',
        'imageReadyTitle': 'الصورة جاهزة!',
        'imageReadyBody': 'تم إنشاء الصورة بنجاح.',
        'generationFailedTitle': 'فشل الإنشاء',
        'timeoutTitle': 'انتهت مهلة الإنشاء',
        'timeoutBody': 'يرجى المحاولة مرة أخرى لاحقًا.',
      };
    } else {
      return {
        'videoReadyTitle': 'Video Ready!',
        'videoReadyBody': 'Your video has been generated successfully.',
        'imageReadyTitle': 'Image Ready!',
        'imageReadyBody': 'Your image has been generated successfully.',
        'generationFailedTitle': 'Generation Failed',
        'timeoutTitle': 'Generation Timed Out',
        'timeoutBody': 'Please try again later.',
      };
    }
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service - call on app startup
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Load saved locale
      await _loadLocale();

      _isInitialized = true;
      debugPrint('NotificationService initialized with locale: $_currentLocale');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to my-creations
    debugPrint('Notification tapped: ${response.payload}');
    // Navigation can be handled via a callback or global navigator key
  }

  /// Request notification permissions (call before showing notifications)
  Future<bool> requestPermissions() async {
    try {
      // Request Android 13+ permissions
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // Request iOS permissions
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Show notification when video generation completes (localized)
  Future<void> showVideoCompleteNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized, skipping notification');
      return;
    }

    // Reload locale in case it changed
    await _loadLocale();
    final strings = _getLocalizedStrings();

    try {
      const androidDetails = AndroidNotificationDetails(
        'video_generation',
        'Video Generation',
        channelDescription: 'Notifications for completed video generation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? strings['videoReadyTitle']!,
        body ?? strings['videoReadyBody']!,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Show notification when image generation completes (localized)
  Future<void> showImageCompleteNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized, skipping notification');
      return;
    }

    // Reload locale in case it changed
    await _loadLocale();
    final strings = _getLocalizedStrings();

    try {
      const androidDetails = AndroidNotificationDetails(
        'image_generation',
        'Image Generation',
        channelDescription: 'Notifications for completed image generation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? strings['imageReadyTitle']!,
        body ?? strings['imageReadyBody']!,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Show notification when generation fails (localized)
  Future<void> showErrorNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    // Reload locale in case it changed
    await _loadLocale();
    final strings = _getLocalizedStrings();

    try {
      const androidDetails = AndroidNotificationDetails(
        'generation_error',
        'Generation Errors',
        channelDescription: 'Notifications for generation errors',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? strings['generationFailedTitle']!,
        body ?? strings['timeoutBody']!,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show error notification: $e');
    }
  }

  /// Show notification when generation times out (localized)
  Future<void> showTimeoutNotification({
    String? payload,
  }) async {
    if (!_isInitialized) return;

    // Reload locale in case it changed
    await _loadLocale();
    final strings = _getLocalizedStrings();

    await showErrorNotification(
      title: strings['timeoutTitle'],
      body: strings['timeoutBody'],
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel notifications: $e');
    }
  }
}
