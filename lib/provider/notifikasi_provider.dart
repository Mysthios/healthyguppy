import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthyguppy/models/notifikasi_model.dart';
import 'package:healthyguppy/services/firebase_service.dart';

// Provider untuk Firebase Service
final firebaseServiceProvider = Provider((ref) => FirebaseService());

// Provider untuk current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return firebaseService.authStateChanges;
});

// Provider untuk authentication state
final authStateProvider = Provider<bool>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return firebaseService.isUserLoggedIn;
});

// Provider untuk daftar semua notifikasi
final notifikasiListProvider = StreamProvider<List<NotificationModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    // Auto-delete old notifications
    firebaseService.deleteOldNotifications().catchError((e) {
      print('Error deleting old notifications: $e');
    });

    return firebaseService.getNotifications();
  } catch (e) {
    print('Error in notifikasiListProvider: $e');
    return Stream.value(<NotificationModel>[]);
  }
});

// Provider untuk unread notification count
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getUnreadNotificationCountStream();
  } catch (e) {
    print('Error getting unread count: $e');
    return Stream.value(0);
  }
});

// Provider untuk notifikasi berdasarkan tipe
final notifikasiByTypeProvider = StreamProvider.family<List<NotificationModel>, String>((ref, type) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getNotificationsByType(type);
  } catch (e) {
    print('Error in notifikasiByTypeProvider: $e');
    return Stream.value(<NotificationModel>[]);
  }
});

// Provider untuk notifikasi terbaru (24 jam terakhir)
final recentNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getRecentNotifications();
  } catch (e) {
    print('Error in recentNotificationsProvider: $e');
    return Stream.value(<NotificationModel>[]);
  }
});

// Provider untuk notifikasi kritis (suhu_alert dan health)
final criticalNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getCriticalNotifications();
  } catch (e) {
    print('Error in criticalNotificationsProvider: $e');
    return Stream.value(<NotificationModel>[]);
  }
});

// Provider untuk jadwal aktif yang akan dijadwalkan
final activeSchedulesProvider = FutureProvider<List<NotificationModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    return firebaseService.getActiveSchedules();
  } catch (e) {
    print('Error in activeSchedulesProvider: $e');
    return <NotificationModel>[];
  }
});

// StateNotifier untuk mengelola aksi notifikasi
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _firebaseService;

  NotificationNotifier(this._firebaseService) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.markNotificationAsRead(notificationId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.markAllNotificationsAsRead();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.deleteNotification(notificationId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearAllNotifications() async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.clearAllNotifications();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    state = const AsyncValue.loading();
    try {
      await _firebaseService.addNotification(notification);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider untuk NotificationNotifier
final notificationNotifierProvider = 
    StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return NotificationNotifier(firebaseService);
});

// Provider untuk filtered notifications (read/unread)
final filteredNotificationsProvider = Provider.family<AsyncValue<List<NotificationModel>>, bool>((ref, showOnlyUnread) {
  final notificationsAsync = ref.watch(notifikasiListProvider);
  
  return notificationsAsync.when(
    data: (notifications) {
      if (showOnlyUnread) {
        final unreadNotifications = notifications.where((notif) => !notif.isRead).toList();
        return AsyncValue.data(unreadNotifications);
      }
      return AsyncValue.data(notifications);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider untuk notification statistics
final notificationStatsProvider = Provider<Map<String, int>>((ref) {
  final notificationsAsync = ref.watch(notifikasiListProvider);
  
  return notificationsAsync.when(
    data: (notifications) {
      final stats = <String, int>{
        'total': notifications.length,
        'unread': notifications.where((n) => !n.isRead).length,
        'suhu_alert': notifications.where((n) => n.type == 'suhu_alert').length,
        'jadwal': notifications.where((n) => n.type == 'jadwal').length,
        'health': notifications.where((n) => n.type == 'health').length,
        'general': notifications.where((n) => n.type == 'general').length,
        'recent': notifications.where((n) => n.isRecent()).length,
        'critical': notifications.where((n) => n.isCritical()).length,
      };
      return stats;
    },
    loading: () => <String, int>{},
    error: (error, stack) => <String, int>{},
  );
});

// Provider untuk sorting notifications
enum NotificationSortType {
  newest,
  oldest,
  priority,
  type,
  unreadFirst,
}

final notificationSortProvider = StateProvider<NotificationSortType>((ref) {
  return NotificationSortType.newest;
});

final sortedNotificationsProvider = Provider<AsyncValue<List<NotificationModel>>>((ref) {
  final notificationsAsync = ref.watch(notifikasiListProvider);
  final sortType = ref.watch(notificationSortProvider);
  
  return notificationsAsync.when(
    data: (notifications) {
      final sortedList = List<NotificationModel>.from(notifications);
      
      switch (sortType) {
        case NotificationSortType.newest:
          sortedList.sort((a, b) => b.waktu.compareTo(a.waktu));
          break;
        case NotificationSortType.oldest:
          sortedList.sort((a, b) => a.waktu.compareTo(b.waktu));
          break;
        case NotificationSortType.priority:
          sortedList.sort((a, b) => b.getPriority().compareTo(a.getPriority()));
          break;
        case NotificationSortType.type:
          sortedList.sort((a, b) => a.type.compareTo(b.type));
          break;
        case NotificationSortType.unreadFirst:
          sortedList.sort((a, b) {
            if (a.isRead == b.isRead) {
              return b.waktu.compareTo(a.waktu);
            }
            return a.isRead ? 1 : -1;
          });
          break;
      }
      
      return AsyncValue.data(sortedList);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});