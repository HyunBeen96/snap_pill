import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/models/app_models.dart';
import '/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'alarmset_model.dart';
export 'alarmset_model.dart';

class AlarmsetWidget extends StatefulWidget {
  final List<PillMedicine> availableMedicines;
  final Function(AlarmSettings) onAlarmSaved;

  const AlarmsetWidget({
    super.key,
    required this.availableMedicines,
    required this.onAlarmSaved,
  });

  @override
  State<AlarmsetWidget> createState() => _AlarmsetWidgetState();
}

class _AlarmsetWidgetState extends State<AlarmsetWidget> with TickerProviderStateMixin {
  late AlarmsetModel _model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 알람 설정 상태
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isDaily = false;
  List<int> selectedWeekdays = [];
  List<String> selectedMedicineIds = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 30));

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlarmsetModel());

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  // 요일 선택 토글
  void toggleWeekday(int weekday) {
    setState(() {
      if (selectedWeekdays.contains(weekday)) {
        selectedWeekdays.remove(weekday);
      } else {
        selectedWeekdays.add(weekday);
      }
    });
  }

  // 약물 선택 토글
  void toggleMedicine(String medicineId) {
    setState(() {
      if (selectedMedicineIds.contains(medicineId)) {
        selectedMedicineIds.remove(medicineId);
      } else {
        selectedMedicineIds.add(medicineId);
      }
    });
  }

  // 알람 저장
  void saveAlarm() {
    if (selectedMedicineIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('복용할 약물을 선택해주세요.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 선택된 각 약물에 대해 알람 생성
    for (String medicineId in selectedMedicineIds) {
      final medicine = widget.availableMedicines.firstWhere((med) => med.id == medicineId);

      final alarm = AlarmSettings(
        id: DateTime.now().millisecondsSinceEpoch.toString() + medicineId,
        medicineId: medicineId,
        medicineName: medicine.name,
        time: selectedTime,
        selectedDays: isDaily ? [1,2,3,4,5,6,7] : selectedWeekdays,
        isRepeating: isDaily || selectedWeekdays.isNotEmpty,
        startDate: startDate,
        endDate: endDate,
        isEnabled: true,
      );

      widget.onAlarmSaved(alarm);
    }

    Navigator.of(context).pop();
  }

  // 드래그로 닫기
  void _handleDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy > 300) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: GestureDetector(
            onTap: () {}, // 내부 탭 시 닫히지 않도록
            onPanEnd: _handleDragEnd,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000).withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 드래그 핸들 및 헤더
                    _buildHeader(),

                    // 컨텐츠
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 안내 카드
                            _buildInfoCard(),
                            SizedBox(height: 24),

                            // 시간 설정
                            _buildTimeSection(),
                            SizedBox(height: 24),

                            // 반복 설정
                            _buildRepeatSection(),
                            SizedBox(height: 24),

                            // 기간 설정
                            _buildDateRangeSection(),
                            SizedBox(height: 24),

                            // 약물 선택
                            _buildMedicineSection(),
                            SizedBox(height: 100), // 버튼 공간
                          ],
                        ),
                      ),
                    ),

                    // 저장 버튼
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더 텍스트
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알람 설정',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '복용 시간과 약물을 설정해주세요',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Color(0xFF64748B)),
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1).withOpacity(0.1),
            Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tips_and_updates, color: Color(0xFF6366F1), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스마트 알림',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '설정한 시간에 정확히 알림을 받으세요',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return _buildSection(
      title: '복용 시간',
      icon: Icons.access_time,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFE2E8F0)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule, color: Color(0xFF6366F1)),
          ),
          title: Text(
            '시간 설정',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            selectedTime.format(context),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Colors.white,
                      hourMinuteShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      dayPeriodShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (time != null) {
              setState(() {
                selectedTime = time;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRepeatSection() {
    return _buildSection(
      title: '반복 설정',
      icon: Icons.repeat,
      child: Column(
        children: [
          // 매일 옵션
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                '매일',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              subtitle: Text(
                '매일 같은 시간에 복용',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              value: isDaily,
              onChanged: (bool? value) {
                setState(() {
                  isDaily = value ?? false;
                  if (isDaily) {
                    selectedWeekdays.clear();
                  }
                });
              },
              activeColor: Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          if (!isDaily) ...[
            SizedBox(height: 16),
            _buildWeekdaySelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    final weekdays = [
      {'day': '월', 'value': 1},
      {'day': '화', 'value': 2},
      {'day': '수', 'value': 3},
      {'day': '목', 'value': 4},
      {'day': '금', 'value': 5},
      {'day': '토', 'value': 6},
      {'day': '일', 'value': 7},
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '요일 선택',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekdays.map((weekday) {
              final isSelected = selectedWeekdays.contains(weekday['value']);
              return InkWell(
                onTap: () => toggleWeekday(weekday['value'] as int),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF6366F1) : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6366F1) : Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      weekday['day'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return _buildSection(
      title: '복용 기간',
      icon: Icons.date_range,
      child: Row(
        children: [
          Expanded(child: _buildDateCard('시작일', startDate, true)),
          SizedBox(width: 12),
          Expanded(child: _buildDateCard('종료일', endDate, false)),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime date, bool isStart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: isStart ? DateTime.now() : startDate,
            lastDate: DateTime.now().add(Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (selectedDate != null) {
            setState(() {
              if (isStart) {
                startDate = selectedDate;
                if (endDate.isBefore(startDate)) {
                  endDate = startDate.add(Duration(days: 30));
                }
              } else {
                endDate = selectedDate;
              }
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isStart ? Icons.play_arrow : Icons.stop,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${date.month}/${date.day}',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineSection() {
    return _buildSection(
      title: '복용할 약물',
      icon: Icons.medication,
      child: widget.availableMedicines.isEmpty
          ? _buildEmptyMedicineState()
          : Column(
        children: widget.availableMedicines.map((medicine) =>
            _buildMedicineCard(medicine)).toList(),
      ),
    );
  }

  Widget _buildEmptyMedicineState() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_outlined,
              size: 32,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '등록된 약물이 없습니다',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '약 검색에서 복용할 약물을 먼저 추가해주세요',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(PillMedicine medicine) {
    final isSelected = selectedMedicineIds.contains(medicine.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Color(0xFF6366F1) : Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => toggleMedicine(medicine.id),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: medicine.imagePath.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    medicine.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.medication, color: Color(0xFF6366F1));
                    },
                  ),
                )
                    : Icon(Icons.medication, color: Color(0xFF6366F1)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      medicine.description,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Color(0xFF6366F1) : Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: saveAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '알람 설정 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF6366F1), size: 20),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        child,
      ],
    );
  }
}