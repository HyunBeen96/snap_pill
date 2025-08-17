import 'package:flutter/material.dart';
import '/models/app_models.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    print('🏗️ AppState 인스턴스 생성됨');
  }

  // 상태 데이터
  List<PillMedicine> _registeredMedicines = [];
  List<AlarmSettings> _alarmSettings = [];
  List<NotificationItem> _notifications = [];

  // Getters
  List<PillMedicine> get registeredMedicines {
    print('📋 등록된 약물 조회: ${_registeredMedicines.length}개');
    return List.unmodifiable(_registeredMedicines);
  }

  List<AlarmSettings> get alarmSettings {
    print('⏰ 알람 설정 조회: ${_alarmSettings.length}개');
    return List.unmodifiable(_alarmSettings);
  }

  List<NotificationItem> get notifications {
    print('🔔 알림 조회: ${_notifications.length}개');
    return List.unmodifiable(_notifications);
  }

  // TimeOfDay를 문자열로 변환하는 헬퍼 함수
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 약물 관리
  void addMedicine(PillMedicine medicine) {
    print('💊 약물 추가 시도: ${medicine.name} (ID: ${medicine.id})');

    // 중복 체크
    bool isDuplicate = _registeredMedicines.any((med) => med.id == medicine.id);
    if (isDuplicate) {
      print('⚠️ 중복된 약물: ${medicine.name}');
      return;
    }

    // 이름으로도 중복 체크
    bool isDuplicateName = _registeredMedicines.any((med) => med.name == medicine.name);
    if (isDuplicateName) {
      print('⚠️ 같은 이름의 약물이 이미 존재: ${medicine.name}');
      return;
    }

    try {
      _registeredMedicines.add(medicine);
      print('✅ 약물 추가 성공: ${medicine.name}');
      print('📊 현재 등록된 약물 수: ${_registeredMedicines.length}');

      // 알림 생성
      addNotification(
          '약 등록 완료',
          '${medicine.name}이(가) 목록에 추가되었습니다.',
          'medicine_added'
      );

      // UI 업데이트 알림
      notifyListeners();
      print('🔄 UI 업데이트 완료');

    } catch (e) {
      print('❌ 약물 추가 실패: $e');
    }
  }

  void removeMedicine(String medicineId) {
    print('🗑️ 약물 삭제 시도: ID $medicineId');

    int initialCount = _registeredMedicines.length;
    _registeredMedicines.removeWhere((med) => med.id == medicineId);
    int finalCount = _registeredMedicines.length;

    if (initialCount > finalCount) {
      print('✅ 약물 삭제 성공: ${initialCount - finalCount}개 삭제됨');

      // 해당 약과 관련된 알람도 삭제
      int initialAlarmCount = _alarmSettings.length;
      _alarmSettings.removeWhere((alarm) => alarm.medicineId == medicineId);
      int finalAlarmCount = _alarmSettings.length;

      if (initialAlarmCount > finalAlarmCount) {
        print('🔔 관련 알람도 삭제됨: ${initialAlarmCount - finalAlarmCount}개');
      }

      notifyListeners();
    } else {
      print('⚠️ 삭제할 약물을 찾을 수 없음: ID $medicineId');
    }
  }

  // 알람 관리
  void addAlarmSetting(AlarmSettings alarm) {
    print('⏰ 알람 설정 추가 시도: ${alarm.medicineName} at ${_formatTimeOfDay(alarm.time)}');

    if (_alarmSettings.length >= 10) {
      print('❌ 알람 개수 제한 (최대 10개)');
      return;
    }

    try {
      _alarmSettings.add(alarm);
      print('✅ 알람 설정 추가 성공');
      print('📊 현재 알람 설정 수: ${_alarmSettings.length}');

      addNotification(
          '알람 설정 완료',
          '${alarm.medicineName} 복용 알람이 설정되었습니다.',
          'pill_alarm'
      );

      notifyListeners();

    } catch (e) {
      print('❌ 알람 설정 추가 실패: $e');
    }
  }

  void removeAlarmSetting(String alarmId) {
    print('🗑️ 알람 설정 삭제 시도: ID $alarmId');

    int initialCount = _alarmSettings.length;
    _alarmSettings.removeWhere((alarm) => alarm.id == alarmId);
    int finalCount = _alarmSettings.length;

    if (initialCount > finalCount) {
      print('✅ 알람 설정 삭제 성공');
      notifyListeners();
    } else {
      print('⚠️ 삭제할 알람을 찾을 수 없음: ID $alarmId');
    }
  }

  void toggleAlarm(String alarmId, bool isEnabled) {
    print('🔄 알람 토글: ID $alarmId, 상태: ${isEnabled ? 'ON' : 'OFF'}');

    final index = _alarmSettings.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      _alarmSettings[index] = _alarmSettings[index].copyWith(isEnabled: isEnabled);
      print('✅ 알람 상태 변경 성공');
      notifyListeners();
    } else {
      print('⚠️ 알람을 찾을 수 없음: ID $alarmId');
    }
  }

  // 알림 관리
  void addNotification(String title, String content, String type) {
    print('🔔 알림 추가: $title');

    try {
      final notification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        timestamp: DateTime.now(),
        type: type,
      );

      _notifications.insert(0, notification);
      print('✅ 알림 추가 성공');
      print('📊 현재 알림 수: ${_notifications.length}');

      // 실제 시스템 알림 생성 (나중에 구현)
      _showSystemNotification(title, content);

      notifyListeners();

    } catch (e) {
      print('❌ 알림 추가 실패: $e');
    }
  }

  void removeNotification(String id) {
    print('🗑️ 알림 삭제 시도: ID $id');

    int initialCount = _notifications.length;
    _notifications.removeWhere((notif) => notif.id == id);
    int finalCount = _notifications.length;

    if (initialCount > finalCount) {
      print('✅ 알림 삭제 성공');
      notifyListeners();
    } else {
      print('⚠️ 삭제할 알림을 찾을 수 없음: ID $id');
    }
  }

  void clearAllNotifications() {
    print('🧹 모든 알림 삭제');

    int count = _notifications.length;
    _notifications.clear();

    print('✅ $count개의 알림이 삭제됨');
    notifyListeners();
  }

  // 시스템 알림 생성 (실제 푸시 알림)
  void _showSystemNotification(String title, String content) {
    // TODO: 실제 시스템 알림 구현
    // 예: flutter_local_notifications 패키지 사용
    print('📢 시스템 알림: $title - $content');
  }

  // 알람 시간 체크 및 알림 생성
  void checkAndTriggerAlarms() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    final currentWeekday = now.weekday; // 1=월, 7=일

    print('⏰ 알람 체크 시작: ${_formatTimeOfDay(currentTime)} (요일: $currentWeekday)');

    for (final alarm in _alarmSettings) {
      if (!alarm.isEnabled) {
        print('⏸️ 비활성화된 알람 건너뜀: ${alarm.medicineName}');
        continue;
      }

      // 날짜 범위 체크
      if (now.isBefore(alarm.startDate) || now.isAfter(alarm.endDate)) {
        print('📅 날짜 범위 벗어남: ${alarm.medicineName}');
        continue;
      }

      // 시간 체크 (분 단위까지)
      if (alarm.time.hour != currentTime.hour ||
          alarm.time.minute != currentTime.minute) {
        continue;
      }

      // 요일 체크
      if (alarm.isRepeating && !alarm.selectedDays.contains(currentWeekday)) {
        print('📆 요일 불일치: ${alarm.medicineName}');
        continue;
      }

      // 알림 생성
      print('🚨 알람 트리거: ${alarm.medicineName}');
      addNotification(
          '💊 복용 시간입니다',
          '${alarm.medicineName}을(를) 복용해주세요.',
          'pill_alarm'
      );
    }
  }

  // 복용 기록 저장 (Record 페이지와 연동)
  void recordMedicationTaken(String medicineId, DateTime date) {
    // TODO: 복용 기록 저장 로직 구현
    // 예: SharedPreferences 또는 SQLite에 저장
    print('📝 복용 기록 저장: $medicineId at $date');
  }

  // 특정 날짜의 복용 기록 조회
  List<String> getMedicationRecordsForDate(DateTime date) {
    // TODO: 저장된 복용 기록 조회 로직 구현
    print('📖 복용 기록 조회: $date');
    return [];
  }

  // 디버깅용 상태 출력
  void printCurrentState() {
    print('=== AppState 현재 상태 ===');
    print('등록된 약물: ${_registeredMedicines.length}개');
    for (var med in _registeredMedicines) {
      print('  - ${med.name} (ID: ${med.id})');
    }
    print('알람 설정: ${_alarmSettings.length}개');
    for (var alarm in _alarmSettings) {
      print('  - ${alarm.medicineName} at ${_formatTimeOfDay(alarm.time)} (${alarm.isEnabled ? 'ON' : 'OFF'})');
    }
    print('알림: ${_notifications.length}개');
    print('========================');
  }
}