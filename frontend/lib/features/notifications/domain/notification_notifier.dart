import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'entities/app_notification.dart';
import 'local_notification_service.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final AppNotification? latestNotification;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.latestNotification,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    AppNotification? latestNotification,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      latestNotification: latestNotification,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> with WidgetsBindingObserver {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;
  RealtimeChannel? _subscription;

  NotificationNotifier(this._ref) : super(NotificationState()) {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  void _init() {
    final user = _ref.read(authProvider).valueOrNull;
    if (user != null) {
      _listenToNotifications(user.id);
      loadNotifications();
    }

    // Heartbeat timer to keep the socket alive on Oppo/Realme/Xiaomi
    Timer.periodic(const Duration(seconds: 40), (timer) {
      if (_subscription != null && _subscription!.isJoined) {
        // Just querying something small to keep the connection active
        _supabase.from('notifications').select('id').limit(1);
      }
    });

    _ref.listen(authProvider, (previous, next) {
      final newUser = next.valueOrNull;
      if (newUser != null && newUser.id != previous?.valueOrNull?.id) {
        _subscription?.unsubscribe();
        _listenToNotifications(newUser.id);
        loadNotifications();
      } else if (newUser == null) {
        _subscription?.unsubscribe();
        state = NotificationState();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-fetch notifications when returning to app to catch any missed while offline
      loadNotifications();
    }
  }

  Future<void> loadNotifications() async {
    final userId = _ref.read(authProvider).valueOrNull?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);
      
      final list = (data as List).map((m) => AppNotification.fromMap(m)).toList();
      state = state.copyWith(notifications: list, isLoading: false);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void _listenToNotifications(String userId) {
    _subscription = _supabase
        .channel('public:notifications:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            final newNotif = AppNotification.fromMap(payload.newRecord);
            
            // 1. SEND RECEIPT: Tell Supabase we received it immediately
            _supabase.from('notifications')
                .update({'received_at': DateTime.now().toIso8601String()})
                .eq('id', newNotif.id);

            // 2. Trigger system notification
            LocalNotificationService.showNotification(
              id: newNotif.hashCode,
              title: newNotif.title,
              body: newNotif.content,
            );

            state = state.copyWith(
              notifications: [newNotif, ...state.notifications],
              latestNotification: newNotif,
            );
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _supabase.from('notifications').update({'is_read': true}).eq('id', id);
      loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void clearLatest() {
    state = state.copyWith(latestNotification: null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});
