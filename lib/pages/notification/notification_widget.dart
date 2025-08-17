import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/models/app_models.dart';
import '/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'notification_model.dart';
export 'notification_model.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> with TickerProviderStateMixin {
  late NotificationModel _model;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationModel());

    // 슬라이드 애니메이션 설정 (위에서 아래로)
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1), // 위에서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // 애니메이션 시작
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  // 드래그로 알림창 닫기
  void _handlePanUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0) return; // 위로 드래그 시 무시

    double progress = details.delta.dy / 200;
    _slideController.value = (1.0 - progress).clamp(0.0, 1.0);
    _fadeController.value = (1.0 - progress * 2).clamp(0.0, 1.0);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy > 300 || _slideController.value < 0.7) {
      _closeNotification();
    } else {
      _slideController.forward();
      _fadeController.forward();
    }
  }

  void _closeNotification() {
    _slideController.reverse();
    _fadeController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _closeNotification,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SafeArea(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      margin: EdgeInsets.only(top: 50),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Color(0xFF000000).withOpacity(0.1),
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {}, // 내부 탭 시 닫히지 않도록
                        child: Column(
                          children: [
                            _buildHeader(appState),
                            Expanded(child: _buildNotificationList(appState)),
                            if (appState.notifications.isNotEmpty)
                              _buildClearAllButton(appState),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
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

          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '최근 활동 내역을 확인하세요',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (appState.notifications.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${appState.notifications.length}',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  IconButton(
                    onPressed: _closeNotification,
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
        ],
      ),
    );
  }

  Widget _buildNotificationList(AppState appState) {
    if (appState.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: appState.notifications.length,
      itemBuilder: (context, index) {
        final notification = appState.notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            appState.removeNotification(notification.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('알림이 삭제되었습니다'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.all(16),
              ),
            );
          },
          background: _buildDismissBackground(Alignment.centerLeft),
          secondaryBackground: _buildDismissBackground(Alignment.centerRight),
          child: _buildNotificationItem(notification, index),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 알림이 도착하면\n여기에 표시됩니다',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            '삭제',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    IconData iconData;
    List<Color> gradientColors;

    switch (notification.type) {
      case 'pill_alarm':
        iconData = Icons.medication;
        gradientColors = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
        break;
      case 'medicine_added':
        iconData = Icons.add_circle;
        gradientColors = [Color(0xFF10B981), Color(0xFF059669)];
        break;
      case 'pharmacy_found':
        iconData = Icons.local_pharmacy;
        gradientColors = [Color(0xFFF59E0B), Color(0xFFD97706)];
        break;
      default:
        iconData = Icons.info;
        gradientColors = [Color(0xFF6B7280), Color(0xFF4B5563)];
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                border: Border.all(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification.content,
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: gradientColors[0].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getTypeText(notification.type),
                                  style: TextStyle(
                                    color: gradientColors[0],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(notification.timestamp),
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClearAllButton(AppState appState) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    '모든 알림 삭제',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  content: Text('모든 알림을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        appState.clearAllNotifications();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('모든 알림이 삭제되었습니다'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: Text(
                        '삭제',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFEF2F2),
            foregroundColor: Color(0xFFEF4444),
            elevation: 0,
            side: BorderSide(color: Color(0xFFFECACA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.clear_all, size: 20),
              SizedBox(width: 8),
              Text(
                '모든 알림 지우기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays < 7) return '${difference.inDays}일 전';

    return '${dateTime.month}/${dateTime.day}';
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'pill_alarm':
        return '복용 알림';
      case 'medicine_added':
        return '약 등록';
      case 'pharmacy_found':
        return '약국 검색';
      default:
        return '알림';
    }
  }
}