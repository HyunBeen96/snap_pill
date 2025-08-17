import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/alarmset/alarmset_widget.dart';
import '/models/app_models.dart';
import '/services/app_state.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pill_alarm_model.dart';
export 'pill_alarm_model.dart';

class PillAlarmWidget extends StatefulWidget {
  const PillAlarmWidget({super.key});

  static String routeName = 'PillAlarm';
  static String routePath = '/pillAlarm';

  @override
  State<PillAlarmWidget> createState() => _PillAlarmWidgetState();
}

class _PillAlarmWidgetState extends State<PillAlarmWidget> {
  late PillAlarmModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PillAlarmModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // 알람 설정 모달 열기
  void _openAlarmSetDialog() async {
    final appState = AppState();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => AlarmsetWidget(
        availableMedicines: appState.registeredMedicines,
        onAlarmSaved: (alarm) {
          appState.addAlarmSetting(alarm);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: Color(0xFFF8FAFC),
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderRadius: 12.0,
                  buttonSize: 40.0,
                  fillColor: Colors.white,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1E293B),
                    size: 20.0,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  '알람 관리',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Pretendard',
                    color: Color(0xFF1E293B),
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: false,
                elevation: 0.0,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 섹션
                      _buildHeaderSection(appState),
                      SizedBox(height: 24),

                      // 설정된 알람 목록
                      _buildAlarmSection(appState),
                      SizedBox(height: 32),

                      // 등록된 약 목록
                      _buildMedicineSection(appState),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(AppState appState) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알람 관리',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '약 복용을 놓치지 마세요',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                '활성 알람',
                '${appState.alarmSettings.where((a) => a.isEnabled).length}개',
                Icons.alarm_on,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                '등록된 약',
                '${appState.registeredMedicines.length}개',
                Icons.medication,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmSection(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '설정된 알람',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openAlarmSetDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          '알람 추가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (appState.alarmSettings.isEmpty)
          _buildEmptyAlarmState()
        else
          ...appState.alarmSettings.map((alarm) => _buildAlarmCard(alarm, appState)),
      ],
    );
  }

  Widget _buildEmptyAlarmState() {
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
              Icons.alarm_off,
              size: 32,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '설정된 알람이 없습니다',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '+ 버튼을 눌러 첫 번째 알람을 설정해보세요',
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

  Widget _buildAlarmCard(AlarmSettings alarm, AppState appState) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: alarm.isEnabled
                      ? [Color(0xFF6366F1), Color(0xFF8B5CF6)]
                      : [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.alarm,
                color: alarm.isEnabled ? Colors.white : Color(0xFF64748B),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.time.format(context),
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    alarm.medicineName,
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (alarm.isRepeating) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRepeatText(alarm.selectedDays),
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: alarm.isEnabled,
                  onChanged: (value) {
                    appState.toggleAlarm(alarm.id, value);
                  },
                  activeColor: Color(0xFF6366F1),
                  activeTrackColor: Color(0xFF6366F1).withOpacity(0.3),
                  inactiveThumbColor: Color(0xFFCBD5E1),
                  inactiveTrackColor: Color(0xFFF1F5F9),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    _showDeleteAlarmDialog(alarm, appState);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineSection(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '등록된 약물',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Pilldata 페이지로 이동
                Navigator.pushNamed(context, '/pilldata');
              },
              icon: Icon(Icons.add_circle_outline, size: 18),
              label: Text('약 추가'),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF6366F1),
                textStyle: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (appState.registeredMedicines.isEmpty)
          _buildEmptyMedicineState()
        else
          ...appState.registeredMedicines.map((medicine) =>
              _buildMedicineCard(medicine, appState)),
      ],
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
            '약 검색에서 복용 중인 약물을 추가해보세요',
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

  Widget _buildMedicineCard(PillMedicine medicine, AppState appState) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Color(0xFF64748B)),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteMedicineDialog(medicine, appState);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAlarmDialog(AlarmSettings alarm, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('알람 삭제'),
        content: Text('${alarm.medicineName} 알람을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              appState.removeAlarmSetting(alarm.id);
              Navigator.of(context).pop();
            },
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteMedicineDialog(PillMedicine medicine, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('약물 삭제'),
        content: Text('${medicine.name}을(를) 목록에서 삭제하시겠습니까?\n관련된 알람도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              appState.removeMedicine(medicine.id);
              Navigator.of(context).pop();
            },
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getRepeatText(List<int> days) {
    if (days.length == 7) return '매일';
    if (days.isEmpty) return '단발성';

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return days.map((day) => weekdays[day - 1]).join(', ');
  }
}