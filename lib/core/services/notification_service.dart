import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

part 'notification_service.g.dart';

@riverpod
class NotificationService extends _$NotificationService {
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;

  @override
  FutureOr<void> build() {
    // Initialisation du service de notifications
  }

  Future<void> initialize() async {
    // Initialiser Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;
    
    // Initialiser les notifications locales
    _localNotifications = FlutterLocalNotificationsPlugin();
    
    // Demander les permissions
    await _requestPermissions();
    
    // Configurer les notifications
    await _configureNotifications();
    
    // Configurer les handlers
    await _configureHandlers();
  }

  Future<void> _requestPermissions() async {
    // Demander les permissions pour les notifications
    final notificationStatus = await Permission.notification.request();
    
    if (notificationStatus.isDenied) {
      // Gérer le refus des permissions
    }
  }

  Future<void> _configureNotifications() async {
    // Configuration des notifications locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Configuration Firebase Messaging
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _configureHandlers() async {
    // Handler pour les notifications en premier plan
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    
    // Handler pour les notifications en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    
    // Handler pour l'ouverture de l'app via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur une notification locale
    final payload = response.payload;
    if (payload != null) {
      // Naviguer vers la page appropriée
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Afficher une notification locale quand l'app est en premier plan
    _showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'DangR',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _onNotificationOpenedApp(RemoteMessage message) {
    // Gérer l'ouverture de l'app via notification Firebase
    final data = message.data;
    // Naviguer vers la page appropriée
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'dangr_channel',
      'DangR Notifications',
      channelDescription: 'Notifications pour les incidents et alertes',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> showHazardNotification({
    required String hazardId,
    required String title,
    required String body,
    required double latitude,
    required double longitude,
  }) async {
    await _showLocalNotification(
      id: hazardId.hashCode,
      title: title,
      body: body,
      payload: 'hazard:$hazardId:$latitude:$longitude',
    );
  }

  Future<void> showEmergencyNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: 'emergency',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// Handler pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Traitement des notifications en arrière-plan
  // Cette fonction doit être au niveau global
}
