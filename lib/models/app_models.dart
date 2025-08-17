import 'package:flutter/material.dart';

// 약물 정보 모델
class PillMedicine {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String manufacturer;
  final String className;

  PillMedicine({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.manufacturer = '',
    this.className = '',
  });

  // SearchModel에서 PillMedicine으로 변환 (실제 SearchModel 속성에 맞춤)
  factory PillMedicine.fromSearchModel(dynamic searchModel) {
    return PillMedicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
      name: searchModel.name ?? '알 수 없는 약물',
      description: '${searchModel.className ?? ''} ${searchModel.description ?? ''}'.trim(),
      imagePath: searchModel.imageUrl ?? '',
      manufacturer: searchModel.manufacturer ?? '',
      className: searchModel.className ?? '',
    );
  }
}

// 알람 설정 모델
class AlarmSettings {
  final String id;
  final String medicineId;
  final String medicineName;
  final TimeOfDay time;
  final List<int> selectedDays; // 1=월, 2=화, ... 7=일
  final bool isRepeating;
  final DateTime startDate;
  final DateTime endDate;
  final bool isEnabled;

  AlarmSettings({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.time,
    required this.selectedDays,
    required this.isRepeating,
    required this.startDate,
    required this.endDate,
    required this.isEnabled,
  });

  AlarmSettings copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    TimeOfDay? time,
    List<int>? selectedDays,
    bool? isRepeating,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
  }) {
    return AlarmSettings(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      time: time ?? this.time,
      selectedDays: selectedDays ?? List.from(this.selectedDays),
      isRepeating: isRepeating ?? this.isRepeating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// 알림 아이템 모델
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String type; // 'pill_alarm', 'medicine_added', 'pharmacy_found'

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.type,
  });
}