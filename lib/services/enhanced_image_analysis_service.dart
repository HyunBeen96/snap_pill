// lib/services/enhanced_image_analysis_service.dart (디버깅 강화 버전)
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../pages/search/search_model.dart';
import 'dart:math' as math;

class EnhancedImageAnalysisService {
  static ImageLabeler? _imageLabeler;
  static TextRecognizer? _textRecognizer;
  static bool _isInitialized = false;

  // ML Kit 초기화 (안전한 버전)
  static Future<bool> initialize() async {
    try {
      print('🚀 ML Kit 초기화 시작...');

      _imageLabeler = ImageLabeler(options: ImageLabelerOptions(
        confidenceThreshold: 0.5, // 임계값 낮춤
      ));
      _textRecognizer = TextRecognizer();

      _isInitialized = true;
      print('✅ ML Kit 초기화 성공');
      return true;
    } catch (e) {
      print('❌ ML Kit 초기화 실패: $e');
      _isInitialized = false;
      return false;
    }
  }

  // 리소스 정리
  static Future<void> dispose() async {
    try {
      await _imageLabeler?.close();
      await _textRecognizer?.close();
      _isInitialized = false;
      print('🧹 ML Kit 리소스 정리 완료');
    } catch (e) {
      print('⚠️ 리소스 정리 중 오류: $e');
    }
  }

  // 향상된 이미지 분석 (안전한 버전)
  static Future<Map<String, dynamic>> analyzeMedicineImage(File imageFile) async {
    print('🔍 === 이미지 분석 시작 ===');
    print('파일 경로: ${imageFile.path}');
    print('파일 존재: ${imageFile.existsSync()}');

    try {
      // 파일 존재 확인
      if (!imageFile.existsSync()) {
        throw Exception('이미지 파일이 존재하지 않습니다');
      }

      // 파일 크기 확인
      int fileSize = await imageFile.length();
      print('파일 크기: ${fileSize} bytes');

      if (fileSize == 0) {
        throw Exception('이미지 파일이 비어있습니다');
      }

      // ML Kit 초기화 시도
      bool mlkitReady = await initialize();
      print('ML Kit 준비 상태: $mlkitReady');

      Map<String, dynamic> analysisResult;

      if (mlkitReady) {
        // AI 기반 분석 시도
        analysisResult = await _performAIAnalysis(imageFile);
      } else {
        // ML Kit 실패 시 기본 분석
        print('⚠️ ML Kit 사용 불가, 기본 분석으로 진행');
        analysisResult = await _fallbackAnalysis(imageFile);
      }

      print('📊 최종 분석 결과: $analysisResult');
      await dispose();
      return analysisResult;

    } catch (e) {
      print('❌ 분석 중 오류: $e');
      print('스택 트레이스: ${StackTrace.current}');

      await dispose();

      // 오류 발생 시에도 기본 결과 반환
      return await _emergencyFallback(imageFile);
    }
  }

  // AI 기반 분석
  static Future<Map<String, dynamic>> _performAIAnalysis(File imageFile) async {
    print('🤖 AI 분석 시작');

    try {
      // InputImage 생성
      final inputImage = InputImage.fromFile(imageFile);
      print('✅ InputImage 생성 성공');

      // 병렬 분석 실행
      List<Future> analysisTask = [
        _performObjectDetection(inputImage),
        _performTextRecognition(inputImage),
        _performAdvancedColorAnalysis(imageFile),
        _performShapeAnalysis(imageFile),
      ];

      print('🔄 병렬 분석 시작...');
      final results = await Future.wait(analysisTask);
      print('✅ 병렬 분석 완료');

      final objectLabels = results[0] as List<String>;
      final extractedText = results[1] as List<String>;
      final colorAnalysis = results[2] as Map<String, dynamic>;
      final shapeAnalysis = results[3] as Map<String, dynamic>;

      print('🏷️ 객체 라벨: $objectLabels');
      print('📝 추출 텍스트: $extractedText');
      print('🎨 색상 분석: ${colorAnalysis['dominantColors']}');
      print('📐 형태 분석: ${shapeAnalysis['predictedShape']}');

      // 종합 신뢰도 계산
      double confidence = _calculateEnhancedConfidence(
          objectLabels, extractedText, colorAnalysis, shapeAnalysis
      );

      print('📊 종합 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%');

      return {
        'colors': colorAnalysis['dominantColors'] ?? [],
        'colorConfidence': colorAnalysis['confidence'] ?? 0.0,
        'shape': shapeAnalysis['predictedShape'] ?? '기타',
        'shapeConfidence': shapeAnalysis['confidence'] ?? 0.0,
        'text': extractedText,
        'objectLabels': objectLabels,
        'size': shapeAnalysis['size'] ?? '알 수 없음',
        'edges': shapeAnalysis['edges'] ?? 0,
        'roundness': shapeAnalysis['roundness'] ?? 0.0,
        'confidence': confidence,
        'analysisMethod': 'AI-Enhanced',
      };

    } catch (e) {
      print('❌ AI 분석 실패: $e');
      return await _fallbackAnalysis(imageFile);
    }
  }

  // Google ML Kit 객체 인식 (안전한 버전)
  static Future<List<String>> _performObjectDetection(InputImage inputImage) async {
    try {
      print('🔍 객체 인식 시작...');

      if (_imageLabeler == null) {
        print('⚠️ ImageLabeler가 null입니다');
        return [];
      }

      final List<ImageLabel> labels = await _imageLabeler!.processImage(inputImage);
      print('📋 감지된 라벨 수: ${labels.length}');

      List<String> medicineRelatedLabels = [];

      for (ImageLabel label in labels) {
        String labelText = label.label.toLowerCase();
        double confidence = label.confidence;

        print('   라벨: "$labelText" (${(confidence * 100).toStringAsFixed(1)}%)');

        // 약물 관련 라벨 필터링 (임계값 낮춤)
        if (_isMedicineRelated(labelText) && confidence > 0.4) {
          medicineRelatedLabels.add(labelText);
          print('   ✅ 약물 관련 라벨로 선택됨');
        }
      }

      print('🏷️ 최종 선택된 라벨: $medicineRelatedLabels');
      return medicineRelatedLabels;

    } catch (e) {
      print('❌ 객체 인식 오류: $e');
      return [];
    }
  }

  // 약물 관련 라벨 판단 (확장된 버전)
  static bool _isMedicineRelated(String label) {
    List<String> medicineKeywords = [
      'pill', 'tablet', 'capsule', 'medicine', 'drug', 'pharmaceutical',
      'medication', 'circle', 'oval', 'round', 'white', 'blue', 'red',
      'yellow', 'green', 'plastic', 'solid', 'sphere', 'object', 'item',
      'food', 'candy', 'supplement' // 확장된 키워드
    ];

    return medicineKeywords.any((keyword) => label.contains(keyword));
  }

  // Google ML Kit 텍스트 인식 (안전한 버전)
  static Future<List<String>> _performTextRecognition(InputImage inputImage) async {
    try {
      print('📝 텍스트 인식 시작...');

      if (_textRecognizer == null) {
        print('⚠️ TextRecognizer가 null입니다');
        return [];
      }

      final RecognizedText recognizedText = await _textRecognizer!.processImage(inputImage);
      print('📄 인식된 텍스트 블록 수: ${recognizedText.blocks.length}');

      List<String> extractedText = [];

      for (TextBlock block in recognizedText.blocks) {
        print('   블록: "${block.text}"');
        for (TextLine line in block.lines) {
          String text = line.text.trim();
          print('     라인: "$text"');

          // 약물 관련 텍스트 필터링
          if (_isValidMedicineText(text)) {
            extractedText.add(text);
            print('     ✅ 유효한 약물 텍스트로 선택됨');
          }
        }
      }

      print('📝 최종 추출된 텍스트: $extractedText');
      return extractedText;

    } catch (e) {
      print('❌ 텍스트 인식 오류: $e');
      return [];
    }
  }

  // 유효한 약물 텍스트 판단 (완화된 기준)
  static bool _isValidMedicineText(String text) {
    // 길이 체크 (더 관대하게)
    if (text.length < 1 || text.length > 25) return false;

    // 특수문자만 있는 경우 제외
    if (RegExp(r'^[^\w\d]+$').hasMatch(text)) return false;

    // 숫자와 문자 조합 체크
    bool hasAlpha = text.contains(RegExp(r'[A-Za-z]'));
    bool hasNumeric = text.contains(RegExp(r'[0-9]'));

    // 일반적인 약물 텍스트 패턴 (더 관대하게)
    List<String> commonPatterns = [
      r'^[A-Z]{1,6}$',           // A, AB, ABC 등 (더 긴 것도 허용)
      r'^[0-9]{1,5}$',           // 10, 20, 500 등 (더 긴 것도 허용)
      r'^[A-Z][0-9]{1,4}$',      // A10, B500 등
      r'^[0-9]{1,4}[A-Z]$',      // 10A, 500B 등
      r'mg$',                     // mg로 끝나는 것
      r'ML$',                     // ML로 끝나는 것
      r'^[A-Z]{2,}[0-9]+$',      // AB123 등
    ];

    bool matchesPattern = commonPatterns.any((pattern) =>
        RegExp(pattern, caseSensitive: false).hasMatch(text)
    );

    // 조건 완화: 패턴 매칭이거나 문자가 있고 길이가 적당하면 허용
    return matchesPattern || (hasAlpha && text.length <= 15);
  }

  // 고급 색상 분석 (안전한 버전)
  static Future<Map<String, dynamic>> _performAdvancedColorAnalysis(File imageFile) async {
    try {
      print('🎨 색상 분석 시작...');

      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        print('❌ 이미지 디코딩 실패');
        throw Exception('이미지 로드 실패');
      }

      print('✅ 이미지 로드 성공: ${image.width}x${image.height}');

      // 이미지 전처리
      image = img.gaussianBlur(image, radius: 1);
      image = img.adjustColor(image, contrast: 1.1, brightness: 1.05);

      // 간단한 색상 추출 (K-means 대신 기본 방식 사용)
      List<String> colorNames = _extractBasicColors(image);
      double colorConfidence = colorNames.isNotEmpty ? 0.7 : 0.1;

      print('🎨 추출된 색상: $colorNames (신뢰도: ${(colorConfidence * 100).toStringAsFixed(1)}%)');

      return {
        'dominantColors': colorNames,
        'confidence': colorConfidence,
        'rgbValues': [], // 간단화
      };

    } catch (e) {
      print('❌ 색상 분석 오류: $e');
      return {
        'dominantColors': <String>[],
        'confidence': 0.0,
        'rgbValues': <List<int>>[],
      };
    }
  }

  // 기본 색상 추출 (안전한 버전)
  static List<String> _extractBasicColors(img.Image image) {
    try {
      Map<String, int> colorCount = {};
      int sampleStep = math.max(1, image.width ~/ 30); // 샘플링 간격 줄임

      for (int y = 0; y < image.height; y += sampleStep) {
        for (int x = 0; x < image.width; x += sampleStep) {
          var pixel = image.getPixel(x, y);
          String colorName = _getBasicColorName(
              pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()
          );

          if (colorName != '배경' && colorName != '기타') {
            colorCount[colorName] = (colorCount[colorName] ?? 0) + 1;
          }
        }
      }

      if (colorCount.isEmpty) {
        return ['하양']; // 기본값
      }

      var sortedColors = colorCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedColors.take(3).map((e) => e.key).toList();

    } catch (e) {
      print('색상 추출 오류: $e');
      return ['하양']; // 안전한 기본값
    }
  }

  // 기본 색상명 추출
  static String _getBasicColorName(int r, int g, int b) {
    double brightness = (r + g + b) / 3.0;

    // 너무 밝거나 어두운 색상은 배경으로 처리
    if (brightness > 240 || brightness < 15) return '배경';

    // 간단한 색상 분류
    if (brightness > 200) return '하양';
    if (brightness < 50) return '검정';

    // RGB 기반 색상 분류
    if (r > g && r > b) {
      if (r > 150) return '빨강';
      return '갈색';
    }
    if (g > r && g > b) {
      if (g > 150) return '초록';
      return '연두';
    }
    if (b > r && b > g) {
      if (b > 150) return '파랑';
      return '남색';
    }
    if (r > 100 && g > 100 && b < 80) return '노랑';
    if (r > 100 && g < 80 && b > 100) return '보라';

    return '회색';
  }

  // 형태 분석 (안전한 버전)
  static Future<Map<String, dynamic>> _performShapeAnalysis(File imageFile) async {
    try {
      print('📐 형태 분석 시작...');

      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) throw Exception('이미지 로드 실패');

      print('✅ 형태 분석용 이미지 로드: ${image.width}x${image.height}');

      // 기본 형태 분석
      double aspectRatio = image.width / image.height;
      String predictedShape = _analyzeBasicShape(image);
      double shapeConfidence = 0.6; // 기본 신뢰도

      print('📐 가로세로비: ${aspectRatio.toStringAsFixed(2)}');
      print('📐 예측 형태: $predictedShape');

      return {
        'predictedShape': predictedShape,
        'confidence': shapeConfidence,
        'aspectRatio': aspectRatio,
        'roundness': 0.5, // 기본값
        'edges': 4, // 기본값
        'size': _categorizeSize(image.width * image.height),
      };

    } catch (e) {
      print('❌ 형태 분석 오류: $e');
      return {
        'predictedShape': '기타',
        'confidence': 0.0,
        'aspectRatio': 1.0,
        'roundness': 0.0,
        'edges': 0,
        'size': '알 수 없음',
      };
    }
  }

  // 기본 형태 분석
  static String _analyzeBasicShape(img.Image image) {
    double aspectRatio = image.width / image.height;

    if (aspectRatio >= 0.85 && aspectRatio <= 1.15) return '원형';
    if (aspectRatio >= 1.3 && aspectRatio <= 2.0) return '장방형';
    if (aspectRatio >= 1.15 && aspectRatio < 1.3) return '타원형';
    return '기타';
  }

  // 크기 분류
  static String _categorizeSize(int area) {
    if (area < 100000) return '소형';
    if (area < 300000) return '중형';
    return '대형';
  }

  // 종합 신뢰도 계산 (완화된 기준)
  static double _calculateEnhancedConfidence(
      List<String> objectLabels,
      List<String> extractedText,
      Map<String, dynamic> colorAnalysis,
      Map<String, dynamic> shapeAnalysis,
      ) {
    double confidence = 0.3; // 기본값 상향

    // AI 객체 인식 결과
    if (objectLabels.isNotEmpty) {
      confidence += 0.2;
    }

    // 텍스트 인식 결과
    if (extractedText.isNotEmpty) {
      confidence += 0.15 * math.min(1.0, extractedText.length / 2.0);
    }

    // 색상 분석 신뢰도
    confidence += (colorAnalysis['confidence'] ?? 0.0) * 0.2;

    // 형태 분석 신뢰도
    confidence += (shapeAnalysis['confidence'] ?? 0.0) * 0.15;

    return confidence.clamp(0.0, 1.0);
  }

  // AI 실패 시 기본 분석으로 폴백
  static Future<Map<String, dynamic>> _fallbackAnalysis(File imageFile) async {
    print('⚠️ 기본 분석으로 폴백');

    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        return _getEmptyResult('Basic-Fallback');
      }

      // 기본 색상 분석
      List<String> colors = _extractBasicColors(image);

      // 기본 형태 분석
      String shape = _analyzeBasicShape(image);

      print('🔄 폴백 분석 결과 - 색상: $colors, 형태: $shape');

      return {
        'colors': colors,
        'colorConfidence': 0.5,
        'shape': shape,
        'shapeConfidence': 0.5,
        'text': <String>[],
        'objectLabels': <String>[],
        'size': _categorizeSize(image.width * image.height),
        'edges': 4,
        'roundness': 0.5,
        'confidence': 0.4, // 폴백 신뢰도
        'analysisMethod': 'Basic-Fallback',
      };

    } catch (e) {
      print('❌ 폴백 분석도 실패: $e');
      return _getEmptyResult('Emergency-Fallback');
    }
  }

  // 긴급 폴백 (최소 결과)
  static Future<Map<String, dynamic>> _emergencyFallback(File imageFile) async {
    print('🚨 긴급 폴백 - 최소 결과 반환');
    return _getEmptyResult('Emergency-Fallback');
  }

  // 빈 결과 생성
  static Map<String, dynamic> _getEmptyResult(String method) {
    return {
      'colors': ['하양'], // 최소한의 색상
      'colorConfidence': 0.2,
      'shape': '원형', // 가장 일반적인 형태
      'shapeConfidence': 0.2,
      'text': <String>[],
      'objectLabels': <String>[],
      'size': '중형',
      'edges': 0,
      'roundness': 0.5,
      'confidence': 0.2, // 낮은 신뢰도
      'analysisMethod': method,
    };
  }

  // 향상된 유사 약물 검색 (임계값 대폭 완화)
  static Future<List<SearchModel>> findSimilarMedicines(
      Map<String, dynamic> analysisResult,
      List<SearchModel> allMedicines,
      ) async {
    print('🔍 === 유사 약물 검색 시작 ===');
    print('전체 약물 수: ${allMedicines.length}');
    print('분석 결과: $analysisResult');

    if (allMedicines.isEmpty) {
      print('❌ 약물 데이터가 없음');
      return [];
    }

    List<MedicineMatch> matches = [];
    String analysisMethod = analysisResult['analysisMethod'] ?? 'Unknown';

    print('분석 방법: $analysisMethod');

    for (int i = 0; i < allMedicines.length; i++) {
      SearchModel medicine = allMedicines[i];
      try {
        double similarity = _calculateAdvancedSimilarity(analysisResult, medicine);

        // 임계값을 대폭 완화 (거의 모든 약물이 결과에 포함되도록)
        double threshold = 0.1; // 매우 낮은 임계값

        if (similarity > threshold) {
          matches.add(MedicineMatch(medicine, similarity));
        }

        // 진행 상황 로그 (100개마다)
        if ((i + 1) % 100 == 0) {
          print('진행: ${i + 1}/${allMedicines.length}, 현재 매칭: ${matches.length}개');
        }

      } catch (e) {
        print('약물 ${medicine.name} 유사도 계산 오류: $e');
      }
    }

    print('📋 총 ${matches.length}개의 유사 약물 발견');

    if (matches.isEmpty) {
      print('⚠️ 유사 약물이 없음 - 상위 20개 약물을 기본 반환');
      // 유사도 관계없이 상위 20개 반환
      return allMedicines.take(20).toList();
    }

    // 유사도 순으로 정렬
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    // 상위 결과만 로그
    for (int i = 0; i < math.min(5, matches.length); i++) {
      var match = matches[i];
      print('상위 ${i + 1}: ${match.medicine.name} (${(match.similarity * 100).toStringAsFixed(1)}%)');
    }

    // 결과 개수 조정
    int resultCount = math.min(30, matches.length); // 최대 30개
    List<SearchModel> results = matches.take(resultCount).map((match) => match.medicine).toList();

    print('🎯 최종 반환: ${results.length}개 약물');
    return results;
  }

  // 고급 유사도 계산 (완화된 기준)
  static double _calculateAdvancedSimilarity(
      Map<String, dynamic> analysisResult,
      SearchModel medicine,
      ) {
    double similarity = 0.1; // 기본 점수 상향
    String analysisMethod = analysisResult['analysisMethod'] ?? 'Basic';

    try {
      // 1. 색상 유사도 (30% 가중치)
      List<String> detectedColors = List<String>.from(analysisResult['colors'] ?? []);
      if (detectedColors.isNotEmpty) {
        double colorScore = 0.0;
        for (String color in detectedColors) {
          if (_isColorMatch(medicine.color, color)) {
            colorScore += 1.0;
            break; // 하나만 매칭되어도 충분
          }
        }
        similarity += (colorScore > 0 ? 0.3 : 0.0);
      }

      // 2. 형태 유사도 (25% 가중치)
      String detectedShape = analysisResult['shape'] ?? '';
      if (detectedShape != '알 수 없음' && detectedShape != '기타') {
        if (_isShapeMatch(medicine.drugShape, detectedShape)) {
          similarity += 0.25;
        }
      }

      // 3. 텍스트 유사도 (20% 가중치)
      List<String> detectedText = List<String>.from(analysisResult['text'] ?? []);
      if (detectedText.isNotEmpty) {
        double textScore = 0.0;
        for (String text in detectedText) {
          if (_isTextMatch(medicine, text)) {
            textScore += 1.0;
            break; // 하나만 매칭되어도 충분
          }
        }
        similarity += (textScore > 0 ? 0.2 : 0.0);
      }

      // 4. 객체 라벨 유사도 (15% 가중치)
      List<String> objectLabels = List<String>.from(analysisResult['objectLabels'] ?? []);
      if (objectLabels.isNotEmpty) {
        double labelScore = 0.0;
        for (String label in objectLabels) {
          if (_isLabelMatch(medicine, label)) {
            labelScore += 1.0;
            break; // 하나만 매칭되어도 충분
          }
        }
        similarity += (labelScore > 0 ? 0.15 : 0.0);
      }

      // 5. 기본 보너스 (10% 가중치)
      similarity += 0.1;

    } catch (e) {
      print('유사도 계산 오류: $e');
      similarity = 0.1; // 오류 시 기본값
    }

    return similarity.clamp(0.0, 1.0);
  }

  // 색상 매칭 (완화된 기준)
  static bool _isColorMatch(String medicineColor, String detectedColor) {
    try {
      String medicineColorLower = medicineColor.toLowerCase();
      String detectedColorLower = detectedColor.toLowerCase();

      // 정확한 매칭
      if (medicineColorLower.contains(detectedColorLower)) return true;

      // 유사 색상 매칭
      Map<String, List<String>> colorSynonyms = {
        '하양': ['흰색', '백색', 'white', '무색'],
        '빨강': ['적색', '빨간색', 'red'],
        '파랑': ['청색', '파란색', 'blue'],
        '노랑': ['황색', '노란색', 'yellow'],
        '초록': ['녹색', '초록색', 'green'],
        '보라': ['자주색', '보라색', 'purple'],
        '주황': ['오렌지', 'orange'],
        '분홍': ['핑크', 'pink'],
        '회색': ['그레이', 'gray', 'grey'],
        '검정': ['흑색', '검은색', 'black'],
        '갈색': ['브라운', 'brown'],
      };

      for (String baseColor in colorSynonyms.keys) {
        List<String> synonyms = colorSynonyms[baseColor] ?? [];
        if ((baseColor == detectedColorLower || synonyms.contains(detectedColorLower)) &&
            (medicineColorLower.contains(baseColor) ||
                synonyms.any((syn) => medicineColorLower.contains(syn)))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('색상 매칭 오류: $e');
      return false;
    }
  }

  // 형태 매칭 (완화된 기준)
  static bool _isShapeMatch(String medicineShape, String detectedShape) {
    try {
      String medicineShapeLower = medicineShape.toLowerCase();
      String detectedShapeLower = detectedShape.toLowerCase();

      // 정확한 매칭
      if (medicineShapeLower.contains(detectedShapeLower)) return true;

      // 형태 동의어 매칭
      Map<String, List<String>> shapeSynonyms = {
        '원형': ['circle', 'round', '둥근', '원'],
        '타원형': ['oval', 'ellipse', '타원', '계란형'],
        '장방형': ['rectangle', 'rectangular', '직사각형', '장방'],
        '사각형': ['square', '정사각형'],
        '삼각형': ['triangle', 'triangular'],
        '마름모': ['diamond', 'rhombus'],
        '다각형': ['polygon', '각형'],
        '기타': ['other', 'irregular'],
      };

      for (String baseShape in shapeSynonyms.keys) {
        List<String> synonyms = shapeSynonyms[baseShape] ?? [];
        if ((baseShape == detectedShapeLower || synonyms.contains(detectedShapeLower)) &&
            (medicineShapeLower.contains(baseShape) ||
                synonyms.any((syn) => medicineShapeLower.contains(syn)))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('형태 매칭 오류: $e');
      return false;
    }
  }

  // 텍스트 매칭 (완화된 기준)
  static bool _isTextMatch(SearchModel medicine, String detectedText) {
    try {
      String textLower = detectedText.toLowerCase();

      // 약물명에서 매칭
      if (medicine.name.toLowerCase().contains(textLower)) return true;

      // 각인에서 매칭
      if (medicine.imprint.toLowerCase().contains(textLower)) return true;

      // 제조사명에서 매칭
      if (medicine.manufacturer.toLowerCase().contains(textLower)) return true;

      // 숫자 패턴 매칭 (용량 정보) - 수정된 부분
      if (RegExp(r'^\d+$').hasMatch(textLower)) {
          String dosagePattern = textLower + 'mg';
          if (medicine.name.toLowerCase().contains(dosagePattern) ||
          medicine.description.toLowerCase().contains(dosagePattern)) {
        return true;
      }

      // mg 없이도 매칭 시도
      if (medicine.name.toLowerCase().contains(textLower) ||
          medicine.description.toLowerCase().contains(textLower)) {
        return true;
      }
    }

    return false;
  } catch (e) {
  print('텍스트 매칭 오류: $e');
  return false;
  }
}

// 객체 라벨 매칭 (완화된 기준)
static bool _isLabelMatch(SearchModel medicine, String label) {
try {
String labelLower = label.toLowerCase();

// 약물 관련 라벨과 분류 매칭
if (labelLower.contains('pill') || labelLower.contains('tablet')) {
return medicine.className.toLowerCase().contains('정') ||
medicine.className.toLowerCase().contains('tablet');
}

if (labelLower.contains('capsule')) {
return medicine.className.toLowerCase().contains('캡슐') ||
medicine.className.toLowerCase().contains('capsule');
}

if (labelLower.contains('round') || labelLower.contains('circle')) {
return medicine.drugShape.toLowerCase().contains('원');
}

if (labelLower.contains('white')) {
return medicine.color.toLowerCase().contains('흰') ||
medicine.color.toLowerCase().contains('하양');
}

// 일반적인 객체들도 약물로 간주
if (labelLower.contains('object') || labelLower.contains('item') ||
labelLower.contains('food') || labelLower.contains('candy')) {
return true;
}

return false;
} catch (e) {
print('라벨 매칭 오류: $e');
return false;
}
}
}

// 약물-유사도 매칭 클래스
class MedicineMatch {
  final SearchModel medicine;
  final double similarity;

  MedicineMatch(this.medicine, this.similarity);

  @override
  String toString() {
    return 'MedicineMatch{${medicine.name}: ${(similarity * 100).toStringAsFixed(1)}%}';
  }
}