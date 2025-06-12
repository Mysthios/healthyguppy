import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthyguppy/provider/sisaPakan_provider.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'package:healthyguppy/services/pakan_service.dart';

class JadwalCheckerService {
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Reference ke ProviderContainer untuk mengakses providers
  final ProviderContainer? _providerContainer;

  // Constructor dengan optional ProviderContainer
  JadwalCheckerService({ProviderContainer? providerContainer}) 
      : _providerContainer = providerContainer;

  // Helper method untuk mendapatkan current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  void startChecking() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndTriggerNotification();
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }

 Future<void> _checkAndTriggerNotification() async {
  // Jangan cek jika user belum login
  if (_currentUserId == null) {
    print('User belum login, skip notification check');
    return;
  }

  final now = DateTime.now();
  final currentDay = DateFormat('EEEE', 'id_ID').format(now);
  final currentHour = now.hour;
  final currentMinute = now.minute;

  try {
    // Hanya ambil jadwal milik user yang sedang login
    final snapshot = await FirebaseFirestore.instance
        .collection('jadwal')
        .where('userId', isEqualTo: _currentUserId) // Filter berdasarkan userId
        .where('isActive', isEqualTo: true) // Hanya jadwal yang aktif
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final hariList = List.from(data['hari'] ?? []);
      final jam = data['jam'] ?? 0;
      final menit = data['menit'] ?? 0;

      // Cek apakah hari ini ada dalam daftar hari jadwal
      bool isToday = hariList.any(
        (hari) => hari.toLowerCase() == currentDay.toLowerCase(),
      );

      if (isToday && jam == currentHour && menit == currentMinute) {
        print('Cocok waktu! Kirim notifikasi untuk user: $_currentUserId');

        // 🔥 KURANGI PAKAN SAAT JADWAL TERPICU
        await _kurangiPakanOtomatis();

        // 🤖 TRIGGER IOT SERVO PAKAN
        await IoTActionService.triggerPakanSequence();

        // Gunakan method yang sama untuk generate notification text
        final title = getNotificationTitle();
        final body = getNotificationBody(jam, menit);

        // Kirim notifikasi
        await NotificationService.showNotification(
          title: title,
          body: body,
        );

        // Simpan notifikasi ke database
        await saveNotificationToDatabase(title, body, now);
      }
    }
  } catch (e) {
    print('Error checking jadwal: $e');
  }
}
  // 🔥 METHOD BARU - Kurangi pakan otomatis saat jadwal terpicu
  Future<void> _kurangiPakanOtomatis() async {
    if (_providerContainer != null) {
      try {
        // Akses SisaPakanNotifier melalui provider container
        final sisaPakanNotifier = _providerContainer.read(sisaPakanProvider.notifier);
        
        // Kurangi pakan sebanyak 1
        await sisaPakanNotifier.kurangiPakan(jumlah: 1);
        
        // Log status pakan setelah dikurangi
        final sisaPakan = _providerContainer.read(sisaPakanProvider);
        print('🍽️ Pakan otomatis berkurang. Sisa: $sisaPakan');
        
        // Cek jika pakan hampir habis atau habis
        if (sisaPakanNotifier.isPakanHabis) {
          print('⚠️ ALERT: Pakan habis! Perlu diisi ulang.');
          // Opsional: Kirim notifikasi khusus untuk pakan habis
          await _sendPakanHabisNotification();
        } else if (sisaPakanNotifier.isPakanHampirHabis) {
          print('⚠️ WARNING: Pakan hampir habis! Sisa: $sisaPakan');
          // Opsional: Kirim notifikasi peringatan
          await _sendPakanHampirHabisNotification(sisaPakan);
        }
      } catch (e) {
        print('❌ Error mengurangi pakan otomatis: $e');
      }
    } else {
      print('⚠️ ProviderContainer tidak tersedia, tidak bisa mengurangi pakan');
    }
  }

  // Method untuk notifikasi pakan habis
  Future<void> _sendPakanHabisNotification() async {
    await NotificationService.showNotification(
      title: '⚠️ Pakan Habis!',
      body: 'Wadah pakan kosong. Segera isi ulang pakan ikan Anda.',
    );
    
    await saveNotificationToDatabase(
      '⚠️ Pakan Habis!',
      'Wadah pakan kosong. Segera isi ulang pakan ikan Anda.',
      DateTime.now(),
      additionalInfo: 'Alert: Pakan habis',
    );
  }

  // Method untuk notifikasi pakan hampir habis
  Future<void> _sendPakanHampirHabisNotification(int sisaPakan) async {
    await NotificationService.showNotification(
      title: '⚠️ Pakan Hampir Habis',
      body: 'Sisa pakan: $sisaPakan. Bersiaplah untuk mengisi ulang.',
    );
    
    await saveNotificationToDatabase(
      '⚠️ Pakan Hampir Habis',
      'Sisa pakan: $sisaPakan. Bersiaplah untuk mengisi ulang.',
      DateTime.now(),
      additionalInfo: 'Warning: Pakan hampir habis',
    );
  }

  // 🔥 PUBLIC METHOD - Reset pakan manual
  Future<void> resetPakan() async {
    if (_providerContainer != null) {
      try {
        final sisaPakanNotifier = _providerContainer.read(sisaPakanProvider.notifier);
        await sisaPakanNotifier.resetPakan();
        
        final sisaPakan = _providerContainer.read(sisaPakanProvider);
        print('🔄 Pakan berhasil di-reset ke: $sisaPakan');
        
        // Kirim notifikasi konfirmasi reset
        await NotificationService.showNotification(
          title: '✅ Pakan Diisi Ulang',
          body: 'Wadah pakan telah diisi penuh ($sisaPakan).',
        );
        
        await saveNotificationToDatabase(
          '✅ Pakan Diisi Ulang',
          'Wadah pakan telah diisi penuh ($sisaPakan).',
          DateTime.now(),
          additionalInfo: 'Manual reset pakan',
        );
      } catch (e) {
        print('❌ Error reset pakan: $e');
      }
    } else {
      print('⚠️ ProviderContainer tidak tersedia, tidak bisa reset pakan');
    }
  }

  // 🔥 PUBLIC METHOD - Isi pakan manual dengan jumlah tertentu
  Future<void> isiPakan({int jumlah = 10}) async {
    if (_providerContainer != null) {
      try {
        final sisaPakanNotifier = _providerContainer.read(sisaPakanProvider.notifier);
        await sisaPakanNotifier.tambahPakan(jumlah: jumlah);
        
        final sisaPakan = _providerContainer.read(sisaPakanProvider);
        print('➕ Pakan berhasil ditambah $jumlah. Total: $sisaPakan');
        
        // Kirim notifikasi konfirmasi
        await NotificationService.showNotification(
          title: '➕ Pakan Ditambah',
          body: 'Ditambah $jumlah pakan. Total sisa: $sisaPakan.',
        );
        
        await saveNotificationToDatabase(
          '➕ Pakan Ditambah',
          'Ditambah $jumlah pakan. Total sisa: $sisaPakan.',
          DateTime.now(),
          additionalInfo: 'Manual tambah pakan: $jumlah',
        );
      } catch (e) {
        print('❌ Error isi pakan: $e');
      }
    }
  }

  // 🔥 PUBLIC METHOD - Cek status pakan
  Map<String, dynamic> getStatusPakan() {
    if (_providerContainer != null) {
      final sisaPakan = _providerContainer.read(sisaPakanProvider);
      final sisaPakanNotifier = _providerContainer.read(sisaPakanProvider.notifier);
      
      return {
        'sisaPakan': sisaPakan,
        'statusPakan': sisaPakanNotifier.statusPakan,
        'persentase': sisaPakanNotifier.persentasePakan,
        'isPakanHabis': sisaPakanNotifier.isPakanHabis,
        'isPakanHampirHabis': sisaPakanNotifier.isPakanHampirHabis,
        'isPakanPenuh': sisaPakanNotifier.isPakanPenuh,
      };
    }
    return {};
  }

  // 🔥 PUBLIC METHODS untuk digunakan dari PopupTambahUpdateJadwal
  
  /// Generate title notifikasi yang konsisten
  String getNotificationTitle() {
    return 'Pengingat Jadwal';
  }

  /// Generate body notifikasi yang konsisten
  String getNotificationBody(int jam, int menit) {
    return 'Sekarang sudah jam ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')} sesuai jadwal!';
  }

  /// Save notification ke database - bisa dipanggil dari luar
  Future<void> saveNotificationToDatabase(
    String title,
    String body,
    DateTime time, {
    String? additionalInfo,
  }) async {
    print('🚀 === saveNotificationToDatabase CALLED ===');
    print('📝 Title: $title');
    print('📝 Body: $body');
    print('📝 Time: $time');
    print('👤 Current User ID: $_currentUserId');
    print('🔐 Auth Current User: ${_auth.currentUser?.uid}');
    
    if (additionalInfo != null) {
      print('ℹ️ Additional Info: $additionalInfo');
    }

    if (_currentUserId == null) {
      print('❌ STOPPING: User ID is null');
      return;
    }

    print('🔄 Attempting to save to Firestore...');

    try {
      // Test koneksi dulu
      print('🌐 Testing Firestore connection...');
      await FirebaseFirestore.instance.enableNetwork();
      print('✅ Network enabled');

      // Simpan data
      print('💾 Adding document to collection...');
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('notifikasi')
          .add({
            'judul': title,
            'isi': body,
            'waktu': FieldValue.serverTimestamp(),
            'userId': _currentUserId,
            'isRead': false,
            'debug_timestamp': DateTime.now().millisecondsSinceEpoch,
            'source': 'jadwal_checker', // Untuk tracking dari mana notifikasi ini
            'additional_info': additionalInfo,
          });

      print('✅ SUCCESS! Document added with ID: ${docRef.id}');

      // Tunggu sebentar lalu verify
      await Future.delayed(Duration(seconds: 2));
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        print('✅ VERIFIED! Document exists in database');
        print('📄 Data: ${snapshot.data()}');
      } else {
        print('❌ WARNING! Document not found after save');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR SAVING: $e');
      print('🔥 Error type: ${e.runtimeType}');
      print('📍 Stack trace: $stackTrace');

      if (e is FirebaseException) {
        print('🔥 Firebase Error Code: ${e.code}');
        print('🔥 Firebase Error Message: ${e.message}');
      }
    }

    print('🏁 === saveNotificationToDatabase FINISHED ===');
  }

  /// Method helper untuk schedule multiple notifications
  Future<void> scheduleNotificationsForJadwal({
    required int jam,
    required int menit,
    required List<String> selectedHari,
    String? customTitle,
    String? customBody,
  }) async {
    print('🚀 === SCHEDULING NOTIFICATIONS FOR JADWAL ===');
    
    final title = customTitle ?? getNotificationTitle();
    final body = customBody ?? getNotificationBody(jam, menit);
    
    print('📝 Using Title: $title');
    print('📝 Using Body: $body');
    print('📅 Days: $selectedHari');
    print('⏰ Time: ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}');

    final baseId = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    
    // Mapping hari Indonesia ke index (Minggu = 0, Senin = 1, dst)
    final hariMapping = {
      'Minggu': 0,
      'Senin': 1,
      'Selasa': 2,
      'Rabu': 3,
      'Kamis': 4,
      'Jumat': 5,
      'Sabtu': 6,
    };

    for (int i = 0; i < selectedHari.length; i++) {
      final hari = selectedHari[i];
      final hariIndex = hariMapping[hari];
      
      if (hariIndex == null) {
        print('❌ Invalid day: $hari');
        continue;
      }
      
      DateTime nextScheduledDate = _getNextScheduledDate(now, hariIndex, jam, menit);
      final notificationId = baseId + i;
      
      try {
        // Schedule notification menggunakan NotificationService
        await NotificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: nextScheduledDate,
        );
        
        // Save preview notification ke database dengan info tambahan
        await saveNotificationToDatabase(
          title,
          body,
          nextScheduledDate,
          additionalInfo: 'Scheduled for $hari at ${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}',
        );
        
        print('✅ Scheduled notification for $hari at $nextScheduledDate');
      } catch (e) {
        print('❌ Failed to schedule notification for $hari: $e');
      }
    }

    print('🏁 === NOTIFICATION SCHEDULING COMPLETED ===');
  }

  /// Helper method untuk menghitung tanggal jadwal berikutnya
  DateTime _getNextScheduledDate(DateTime now, int targetDayOfWeek, int targetHour, int targetMinute) {
    int currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;
    int daysUntilTarget = (targetDayOfWeek - currentDayOfWeek) % 7;
    
    if (daysUntilTarget == 0) {
      final targetTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
      if (targetTime.isBefore(now)) {
        daysUntilTarget = 7;
      }
    }
    
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      targetHour,
      targetMinute,
    );
    
    return scheduledDate;
  }

  /// Method untuk cancel semua scheduled notifications (untuk edit/delete jadwal)
  Future<void> cancelScheduledNotifications(List<int> notificationIds) async {
    print('🗑️ Cancelling scheduled notifications: $notificationIds');
    
    try {
      for (int id in notificationIds) {
        await NotificationService.cancelNotification(id);
        print('✅ Cancelled notification ID: $id');
      }
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  // Method untuk restart checker ketika user login/logout
  void restartForUser() {
    stopChecking();
    if (_currentUserId != null) {
      startChecking();
    }
  }

  // Getter untuk mengakses user ID dari luar (jika diperlukan)
  String? get currentUserId => _currentUserId;

  // Method untuk test notification (untuk debugging)
  Future<void> testNotification() async {
    final title = getNotificationTitle();
    final body = getNotificationBody(DateTime.now().hour, DateTime.now().minute);
    
    await NotificationService.showNotification(
      title: title,
      body: body,
    );
    
    await saveNotificationToDatabase(
      title,
      body,
      DateTime.now(),
      additionalInfo: 'Test notification',
    );
    
    print('🧪 Test notification sent and saved');
  }

  // 🔥 METHOD UNTUK TEST PAKAN (debugging)
  Future<void> testKurangiPakan() async {
    print('🧪 === TEST KURANGI PAKAN ===');
    await _kurangiPakanOtomatis();
    final status = getStatusPakan();
    print('📊 Status pakan setelah test: $status');
  }
}