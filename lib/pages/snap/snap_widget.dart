// 디버깅이 강화된 snap_widget.dart
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'snap_model.dart';
import '/pages/search/search_widget.dart';
import '/pages/search/search_model.dart';
export 'snap_model.dart';
// 디버깅 강화된 분석 서비스 import
import '/services/enhanced_image_analysis_service.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraImageCropper {

  // 가이드라인 프레임 정보
  static const double GUIDELINE_SIZE = 220.0;

  // 카메라 해상도와 프리뷰 크기를 고려한 크롭 함수
  static Future<File> cropToGuidelineArea(
      File originalImageFile,
      CameraController cameraController,
      Size previewSize,
      ) async {
    try {
      print('🔧 이미지 크롭 시작...');

      // 1. 원본 이미지 로드
      Uint8List imageBytes = await originalImageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('이미지를 읽을 수 없습니다');
      }

      print('📷 원본 이미지 크기: ${originalImage.width}x${originalImage.height}');
      print('📱 프리뷰 크기: ${previewSize.width}x${previewSize.height}');

      // 2. 카메라 해상도 대비 프리뷰 비율 계산
      double scaleX = originalImage.width / previewSize.width;
      double scaleY = originalImage.height / previewSize.height;

      print('📐 스케일 비율: X=${scaleX.toStringAsFixed(2)}, Y=${scaleY.toStringAsFixed(2)}');

      // 3. 가이드라인 프레임의 실제 이미지상 좌표 계산
      // 프리뷰에서 중앙에 위치한 220x220 프레임을 실제 이미지 좌표로 변환
      double centerX = previewSize.width / 2;
      double centerY = previewSize.height / 2;

      double frameLeft = centerX - (GUIDELINE_SIZE / 2);
      double frameTop = centerY - (GUIDELINE_SIZE / 2);

      // 실제 이미지 좌표로 변환
      int cropX = (frameLeft * scaleX).round();
      int cropY = (frameTop * scaleY).round();
      int cropWidth = (GUIDELINE_SIZE * scaleX).round();
      int cropHeight = (GUIDELINE_SIZE * scaleY).round();

      // 경계값 검사 및 조정
      cropX = cropX.clamp(0, originalImage.width - 1);
      cropY = cropY.clamp(0, originalImage.height - 1);
      cropWidth = (cropX + cropWidth > originalImage.width)
          ? originalImage.width - cropX
          : cropWidth;
      cropHeight = (cropY + cropHeight > originalImage.height)
          ? originalImage.height - cropY
          : cropHeight;

      print('✂️ 크롭 영역: x=$cropX, y=$cropY, w=$cropWidth, h=$cropHeight');

      // 4. 이미지 크롭 실행
      img.Image croppedImage = img.copyCrop(
          originalImage,
          x: cropX,
          y: cropY,
          width: cropWidth,
          height: cropHeight
      );

      print('✅ 크롭 완료: ${croppedImage.width}x${croppedImage.height}');

      // 5. 크롭된 이미지를 임시 파일로 저장
      String croppedPath = originalImageFile.path.replaceAll('.jpg', '_cropped.jpg');
      File croppedFile = File(croppedPath);

      List<int> croppedBytes = img.encodeJpg(croppedImage, quality: 90);
      await croppedFile.writeAsBytes(croppedBytes);

      print('💾 크롭된 이미지 저장: $croppedPath');

      return croppedFile;

    } catch (e) {
      print('❌ 이미지 크롭 실패: $e');
      // 크롭 실패 시 원본 반환
      return originalImageFile;
    }
  }

  // 프리뷰 크기 계산 헬퍼 함수
  static Size calculatePreviewSize(CameraController controller, Size screenSize) {
    if (!controller.value.isInitialized) {
      return screenSize;
    }

    // 카메라 해상도
    Size cameraSize = Size(
        controller.value.previewSize!.height, // 회전됨
        controller.value.previewSize!.width
    );

    // 화면에 맞춘 프리뷰 크기 계산 (aspect ratio 유지)
    double screenAspect = screenSize.width / screenSize.height;
    double cameraAspect = cameraSize.width / cameraSize.height;

    Size previewSize;
    if (screenAspect > cameraAspect) {
      // 화면이 더 가로로 길 때
      previewSize = Size(
          screenSize.height * cameraAspect,
          screenSize.height
      );
    } else {
      // 화면이 더 세로로 길 때
      previewSize = Size(
          screenSize.width,
          screenSize.width / cameraAspect
      );
    }

    return previewSize;
  }
}

class SnapWidget extends StatefulWidget {
  const SnapWidget({super.key});

  @override
  State<SnapWidget> createState() => _SnapWidgetState();
}

class _SnapWidgetState extends State<SnapWidget> with WidgetsBindingObserver {
  late SnapModel _model;
  final ImagePicker _picker = ImagePicker();

  // 카메라 관련 변수
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;

  File? _capturedImage;
  bool _isProcessing = false;
  String _processingStatus = '이미지를 분석하고 있습니다...';
  double _processingProgress = 0.0;

  // 디버깅용 변수
  List<String> _debugLogs = [];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SnapModel());
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _addDebugLog('SnapWidget 초기화 완료');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    EnhancedImageAnalysisService.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  // 디버그 로그 추가
  void _addDebugLog(String message) {
    print('🐛 DEBUG: $message');
    setState(() {
      _debugLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_debugLogs.length > 10) {
        _debugLogs.removeAt(0);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      _addDebugLog('카메라 초기화 시작');
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        _addDebugLog('사용 가능한 카메라가 없음');
        return;
      }

      _selectedCameraIndex = 0;

      _cameraController = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      _addDebugLog('카메라 초기화 성공');
    } catch (e) {
      _addDebugLog('카메라 초기화 실패: $e');
    }
  }

  // 카메라 전환
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      _addDebugLog('전환 가능한 카메라가 없음');
      return;
    }

    try {
      await _cameraController?.dispose();
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

      _cameraController = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      _addDebugLog('카메라 전환 완료');
    } catch (e) {
      _addDebugLog('카메라 전환 실패: $e');
    }
  }

  // 플래시 토글
  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off
      );

      setState(() {});
      _addDebugLog('플래시 ${_isFlashOn ? "켜짐" : "꺼짐"}');
    } catch (e) {
      _addDebugLog('플래시 제어 실패: $e');
    }
  }

  // 향상된 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showErrorDialog('카메라가 준비되지 않았습니다.');
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _processingStatus = '사진을 촬영하고 있습니다...';
        _processingProgress = 0.1;
      });

      _addDebugLog('사진 촬영 시작');

      // 플래시가 켜져있으면 잠시 끄기
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }

      // 사진 촬영
      final XFile photo = await _cameraController!.takePicture();
      _capturedImage = File(photo.path);

      _addDebugLog('사진 촬영 완료: ${photo.path}');

      setState(() {
        _processingProgress = 0.2;
        _processingStatus = 'AI가 이미지를 분석하고 있습니다...';
      });

      // 향상된 이미지 분석 및 검색 실행
      await _performEnhancedAnalysisAndSearch();

    } catch (e) {
      _addDebugLog('촬영 실패: $e');
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('사진 촬영에 실패했습니다: ${e.toString()}');
    }
  }

  // 갤러리에서 사진 선택
  Future<void> _pickFromGallery() async {
    try {
      _addDebugLog('갤러리 접근 시작');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _isProcessing = true;
          _processingStatus = 'AI가 이미지를 분석하고 있습니다...';
          _processingProgress = 0.1;
        });

        _addDebugLog('갤러리 이미지 선택: ${image.path}');
        await _performEnhancedAnalysisAndSearch();
      } else {
        _addDebugLog('갤러리에서 이미지 선택 취소');
      }
    } catch (e) {
      _addDebugLog('갤러리 오류: $e');
      _showErrorDialog('갤러리에 접근할 수 없습니다.');
    }
  }

  // 향상된 이미지 분석 및 검색 (디버깅 강화)
  Future<void> _performEnhancedAnalysisAndSearch() async {
    if (_capturedImage == null) {
      _addDebugLog('캡처된 이미지가 없음');
      return;
    }

    try {
      _addDebugLog('=== 분석 프로세스 시작 ===');

      // 1단계: 파일 검증
      setState(() {
        _processingStatus = '이미지 파일을 검증하고 있습니다...';
        _processingProgress = 0.1;
      });

      bool fileExists = _capturedImage!.existsSync();
      int fileSize = await _capturedImage!.length();
      _addDebugLog('파일 존재: $fileExists, 크기: $fileSize bytes');

      if (!fileExists || fileSize == 0) {
        throw Exception('이미지 파일이 유효하지 않습니다');
      }

      // 2단계: AI 이미지 분석
      setState(() {
        _processingStatus = 'AI가 약물 특성을 분석하고 있습니다...';
        _processingProgress = 0.3;
      });

      _addDebugLog('AI 이미지 분석 시작');
      Map<String, dynamic> analysisResult =
      await EnhancedImageAnalysisService.analyzeMedicineImage(_capturedImage!);

      _addDebugLog('AI 분석 완료: ${analysisResult['analysisMethod']}');
      _addDebugLog('신뢰도: ${(analysisResult['confidence'] * 100).toStringAsFixed(1)}%');

      // 3단계: JSON 데이터 로드
      setState(() {
        _processingStatus = '약물 데이터베이스를 로딩하고 있습니다...';
        _processingProgress = 0.5;
      });

      _addDebugLog('약물 데이터베이스 로딩 시작');
      String jsonStr = await rootBundle.loadString('assets/tablet_data_final.json');

      // NaN 값 처리
      jsonStr = jsonStr.replaceAll(': NaN,', ': null,');
      jsonStr = jsonStr.replaceAll(': NaN}', ': null}');

      List<dynamic> jsonData = json.decode(jsonStr);
      _addDebugLog('JSON 파싱 완료: ${jsonData.length}개 항목');

      // SearchModel 리스트 생성
      List<SearchModel> allMedicines = [];
      int successCount = 0;
      int errorCount = 0;

      for (var item in jsonData) {
        try {
          if (item != null && item is Map<String, dynamic>) {
            allMedicines.add(SearchModel.fromJson(Map<String, dynamic>.from(item)));
            successCount++;
          }
        } catch (e) {
          errorCount++;
        }
      }

      _addDebugLog('약물 모델 생성: 성공 $successCount개, 오류 $errorCount개');

      // 4단계: 유사한 약물 검색
      setState(() {
        _processingStatus = 'AI가 유사한 약물을 검색하고 있습니다...';
        _processingProgress = 0.7;
      });

      _addDebugLog('유사 약물 검색 시작');
      List<SearchModel> similarMedicines =
      await EnhancedImageAnalysisService.findSimilarMedicines(analysisResult, allMedicines);

      _addDebugLog('유사 약물 검색 완료: ${similarMedicines.length}개');

      // 5단계: 결과 준비
      setState(() {
        _processingStatus = '검색 결과를 준비하고 있습니다...';
        _processingProgress = 0.9;
      });

      _addDebugLog('=== 최종 결과 ===');
      _addDebugLog('분석 방법: ${analysisResult['analysisMethod']}');
      _addDebugLog('신뢰도: ${(analysisResult['confidence'] * 100).toStringAsFixed(1)}%');
      _addDebugLog('색상: ${analysisResult['colors']}');
      _addDebugLog('형태: ${analysisResult['shape']}');
      _addDebugLog('텍스트: ${analysisResult['text']}');
      _addDebugLog('유사 약물: ${similarMedicines.length}개');

      setState(() {
        _isProcessing = false;
      });

      // 6단계: Search 페이지로 이동
      _addDebugLog('검색 페이지로 이동');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SearchWidget(
            searchKeyword: "",
            isImageSearch: true,
            capturedImagePath: _capturedImage!.path,
            analysisResult: analysisResult,
            similarMedicines: similarMedicines,
          ),
        ),
      );

    } catch (e, stackTrace) {
      _addDebugLog('분석 중 오류: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isProcessing = false;
      });

      _showErrorDialog('이미지 분석 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 16),
              Text('디버그 로그:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 200,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    _debugLogs.join('\n'),
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: _isProcessing
            ? _buildEnhancedProcessingView()
            : _buildCameraView(),
      ),
    );
  }

  Widget _buildEnhancedProcessingView() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI 분석 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: FlutterFlowTheme.of(context).primary,
                size: 60,
              ),
            ),

            SizedBox(height: 32),

            // 진행 상태 텍스트
            Text(
              _processingStatus,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            // 진행률 표시
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _processingProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 진행률 퍼센트
            Text(
              '${(_processingProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),

            if (_capturedImage != null) ...[
              SizedBox(height: 32),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            SizedBox(height: 24),

            // 디버그 로그 표시
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        '실시간 로그',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 80,
                    child: SingleChildScrollView(
                      child: Text(
                        _debugLogs.isEmpty ? '로그 없음' : _debugLogs.join('\n'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        // 상단 헤더 (디버그 정보 포함)
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: Color(0x33FFFFFF),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  Column(
                    children: [
                      Text(
                        'AI 약품 인식 (DEBUG)',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.poppins(),
                          color: Colors.white,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Enhanced with ML Kit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: _isFlashOn ? FlutterFlowTheme.of(context).primary : Color(0x33FFFFFF),
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),

              // 디버그 로그 표시 (간단 버전)
              if (_debugLogs.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _debugLogs.last,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),

        // 카메라 프리뷰 영역
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: _isCameraInitialized && _cameraController != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // 카메라 프리뷰
                    CameraPreview(_cameraController!),

                    // 향상된 가이드라인 오버레이
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            // 모서리 강조선
                            Positioned(
                              top: -3,
                              left: -3,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.white, width: 4),
                                    left: BorderSide(color: Colors.white, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.white, width: 4),
                                    right: BorderSide(color: Colors.white, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -3,
                              left: -3,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white, width: 4),
                                    left: BorderSide(color: Colors.white, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -3,
                              right: -3,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white, width: 4),
                                    right: BorderSide(color: Colors.white, width: 4),
                                  ),
                                ),
                              ),
                            ),

                            // 중앙 안내 텍스트
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.medication,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '약품을 프레임 안에\n맞춰주세요',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 상단 AI 정보 배지
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.psychology, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'AI DEBUG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(
                  color: Color(0xFF1A1A1A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '카메라를 초기화하고 있습니다...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 하단 컨트롤 영역 (픽셀 오버플로우 방지)
        Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 기능 설명 (디버그 모드) - 높이 고정
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'DEBUG 모드: AI 분석 로그 표시',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 컨트롤 버튼들 - 크기 조정
              Container(
                height: 100, // 고정 높이
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 갤러리 버튼 - 크기 축소
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 55.0,
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(27.5),
                              border: Border.all(color: Colors.white, width: 2.0),
                            ),
                            child: FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 27.5,
                              buttonSize: 55.0,
                              fillColor: Colors.transparent,
                              icon: Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              onPressed: _pickFromGallery,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '앨범',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    // 촬영 버튼 (디버그 버전) - 크기 축소
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 75.0,
                            height: 75.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.8), // 디버그 모드 표시
                                  FlutterFlowTheme.of(context).primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(37.5),
                              border: Border.all(color: Colors.white, width: 3.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 37.5,
                              buttonSize: 75.0,
                              fillColor: Colors.transparent,
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32.0,
                              ),
                              onPressed: _isCameraInitialized ? _takePicture : null,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'AI 촬영',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    // 카메라 전환 버튼 - 크기 축소
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 55.0,
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(27.5),
                              border: Border.all(color: Colors.white, width: 2.0),
                            ),
                            child: FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 27.5,
                              buttonSize: 55.0,
                              fillColor: Colors.transparent,
                              icon: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              onPressed: _cameras != null && _cameras!.length > 1
                                  ? _switchCamera
                                  : null,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '전환',
                            style: TextStyle(
                              color: _cameras != null && _cameras!.length > 1
                                  ? Colors.white
                                  : Colors.grey,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}