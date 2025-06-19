// lib/services/image_analysis_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../pages/search/search_model.dart';

class ImageAnalysisService {
  static const String _jsonPath = 'assets/tablet_data_final.json';

  // 이미지에서 약물 특성 추출
  static Future<Map<String, dynamic>> analyzeMedicineImage(File imageFile) async {
    try {
      print('🔍 이미지 분석 시작: ${imageFile.path}');

      // 이미지 로드 및 전처리
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('이미지를 읽을 수 없습니다.');
      }

      print('✅ 이미지 로드 완료: ${originalImage.width}x${originalImage.height}');

      // 이미지 크기 조정 (성능 최적화)
      img.Image resizedImage = img.copyResize(originalImage, width: 300);

      // 색상 분석
      List<String> dominantColors = _extractDominantColors(resizedImage);
      print('🎨 주요 색상: $dominantColors');

      // 모양 분석 (간단한 윤곽선 기반)
      String shape = _analyzeShape(resizedImage);
      print('📐 예상 모양: $shape');

      // 크기 분석
      String size = _analyzeSize(resizedImage);
      print('📏 크기 분류: $size');

      // 텍스트 추출 (OCR 시뮬레이션)
      List<String> extractedText = await _extractText(resizedImage);
      print('📝 추출된 텍스트: $extractedText');

      double confidence = _calculateConfidence(dominantColors, shape, extractedText);
      print('📊 분석 신뢰도: ${(confidence * 100).toStringAsFixed(1)}%');

      return {
        'colors': dominantColors,
        'shape': shape,
        'size': size,
        'text': extractedText,
        'confidence': confidence,
      };
    } catch (e) {
      print('❌ 이미지 분석 오류: $e');
      return {
        'colors': <String>[],
        'shape': '알 수 없음',
        'size': '알 수 없음',
        'text': <String>[],
        'confidence': 0.0,
      };
    }
  }

  // 분석 결과를 바탕으로 유사한 약물 검색
  static Future<List<SearchModel>> findSimilarMedicines(
      Map<String, dynamic> analysisResult,
      List<SearchModel> allMedicines,
      ) async {
    print('🔍 유사 약물 검색 시작 (전체 ${allMedicines.length}개 약물)');

    List<MedicineMatch> matches = [];

    for (SearchModel medicine in allMedicines) {
      double similarity = _calculateSimilarity(analysisResult, medicine);
      if (similarity > 0.2) { // 최소 20% 유사도로 낮춤
        matches.add(MedicineMatch(medicine, similarity));
      }
    }

    print('📋 ${matches.length}개의 유사 약물 발견');

    // 유사도 순으로 정렬
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    // 상위 20개만 반환
    List<SearchModel> results = matches.take(20).map((match) => match.medicine).toList();

    print('🎯 상위 ${results.length}개 약물 반환');
    return results;
  }

  // 주요 색상 추출 (수정된 버전 - image 라이브러리 4.x 대응)
  static List<String> _extractDominantColors(img.Image image) {
    Map<String, int> colorCount = {};
    int totalPixels = 0;

    // 색상별 픽셀 수 계산 (샘플링으로 성능 최적화)
    for (int y = 0; y < image.height; y += 3) {
      for (int x = 0; x < image.width; x += 3) {
        // image 4.x에서는 getPixel이 Pixel 객체를 반환
        var pixel = image.getPixel(x, y);
        String colorName = _getColorName(pixel);

        // 배경색(너무 밝거나 어두운 색) 제외
        if (colorName != '배경') {
          colorCount[colorName] = (colorCount[colorName] ?? 0) + 1;
          totalPixels++;
        }
      }
    }

    // 전체 픽셀의 5% 이상을 차지하는 색상만 선택
    int threshold = (totalPixels * 0.05).round();

    var significantColors = colorCount.entries
        .where((entry) => entry.value >= threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return significantColors.take(3).map((e) => e.key).toList();
  }

  // RGB 값을 색상명으로 변환 (image 4.x 대응)
  static String _getColorName(dynamic pixel) {
    // image 4.x에서는 Pixel 객체의 r, g, b 속성 사용
    int r = pixel.r.toInt();
    int g = pixel.g.toInt();
    int b = pixel.b.toInt();

    // 밝기 계산
    double brightness = (r + g + b) / 3.0;

    // 너무 밝거나 어두운 색상은 배경으로 처리
    if (brightness > 240 || brightness < 15) return '배경';

    // 채도 계산
    int max = [r, g, b].reduce((a, b) => a > b ? a : b);
    int min = [r, g, b].reduce((a, b) => a < b ? a : b);
    double saturation = max == 0 ? 0 : (max - min) / max;

    // 무채색 판별
    if (saturation < 0.2) {
      if (brightness > 180) return '하양';
      if (brightness < 60) return '검정';
      return '회색';
    }

    // 색상 판별 (HSV 기반)
    double h = _getHue(r, g, b);

    if (h >= 0 && h < 30) return '빨강';
    if (h >= 30 && h < 90) return '노랑';
    if (h >= 90 && h < 150) return '초록';
    if (h >= 150 && h < 210) return '청록';
    if (h >= 210 && h < 270) return '파랑';
    if (h >= 270 && h < 330) return '보라';
    if (h >= 330) return '빨강';

    return '기타';
  }

  // HSV의 H(색상) 값 계산
  static double _getHue(int r, int g, int b) {
    double rNorm = r / 255.0;
    double gNorm = g / 255.0;
    double bNorm = b / 255.0;

    double max = [rNorm, gNorm, bNorm].reduce((a, b) => a > b ? a : b);
    double min = [rNorm, gNorm, bNorm].reduce((a, b) => a < b ? a : b);

    if (max == min) return 0; // 무채색

    double delta = max - min;
    double hue = 0;

    if (max == rNorm) {
      hue = ((gNorm - bNorm) / delta) % 6;
    } else if (max == gNorm) {
      hue = (bNorm - rNorm) / delta + 2;
    } else {
      hue = (rNorm - gNorm) / delta + 4;
    }

    return hue * 60;
  }

  // 모양 분석 (개선된 버전)
  static String _analyzeShape(img.Image image) {
    int width = image.width;
    int height = image.height;
    double aspectRatio = width / height;

    // 가로세로 비율 기반 형태 분류
    if (aspectRatio >= 0.85 && aspectRatio <= 1.15) {
      // 정사각형에 가까운 형태 - 원형 또는 정사각형 가능성
      return '원형';
    } else if (aspectRatio >= 1.3 && aspectRatio <= 2.0) {
      // 직사각형 형태
      return '장방형';
    } else if (aspectRatio >= 1.15 && aspectRatio < 1.3) {
      // 약간 긴 타원 형태
      return '타원형';
    } else if (aspectRatio < 0.85) {
      // 세로가 더 긴 형태
      return '기타';
    }

    return '기타';
  }

  // 크기 분석
  static String _analyzeSize(img.Image image) {
    int area = image.width * image.height;

    // 상대적 크기 분류 (리사이즈된 이미지 기준)
    if (area < 15000) return '소형';
    if (area < 30000) return '중형';
    return '대형';
  }

  // 텍스트 추출 (OCR 시뮬레이션 - 추후 실제 OCR로 교체)
  static Future<List<String>> _extractText(img.Image image) async {
    // TODO: Google ML Kit Text Recognition 또는 다른 OCR 라이브러리 사용
    // 현재는 랜덤 시뮬레이션
    await Future.delayed(Duration(milliseconds: 500));

    // 이미지 복잡도에 따라 다른 결과 반환
    List<String> possibleTexts = ['A', 'B', 'C', '10', '20', '50', 'MG', 'mg'];

    // 랜덤하게 0-3개의 텍스트 반환
    int textCount = (image.width * image.height / 10000).round().clamp(0, 3);
    possibleTexts.shuffle();

    return possibleTexts.take(textCount).toList();
  }

  // 신뢰도 계산
  static double _calculateConfidence(
      List<String> colors,
      String shape,
      List<String> text,
      ) {
    double confidence = 0.3; // 기본 신뢰도

    // 색상 정보가 있으면 신뢰도 증가
    if (colors.isNotEmpty) {
      confidence += 0.3 * (colors.length / 3.0); // 최대 0.3 추가
    }

    // 모양 정보가 있으면 신뢰도 증가
    if (shape != '알 수 없음' && shape != '기타') {
      confidence += 0.25;
    }

    // 텍스트 정보가 있으면 신뢰도 증가
    if (text.isNotEmpty) {
      confidence += 0.15 * (text.length / 3.0); // 최대 0.15 추가
    }

    return confidence.clamp(0.0, 1.0);
  }

  // 유사도 계산 (개선된 버전)
  static double _calculateSimilarity(
      Map<String, dynamic> analysisResult,
      SearchModel medicine,
      ) {
    double similarity = 0.0;

    // 색상 유사도 (50% 가중치) - 가장 중요한 요소
    List<String> detectedColors = analysisResult['colors'] ?? [];
    if (detectedColors.isNotEmpty) {
      double colorScore = 0.0;
      for (String color in detectedColors) {
        if (medicine.color.toLowerCase().contains(color.toLowerCase())) {
          colorScore += 1.0;
        }
      }
      similarity += (colorScore / detectedColors.length) * 0.5;
    }

    // 모양 유사도 (25% 가중치)
    String detectedShape = analysisResult['shape'] ?? '';
    if (detectedShape != '알 수 없음' && detectedShape != '기타') {
      if (medicine.drugShape.toLowerCase().contains(detectedShape.toLowerCase())) {
        similarity += 0.25;
      }
    }

    // 텍스트 유사도 (20% 가중치)
    List<String> detectedText = analysisResult['text'] ?? [];
    if (detectedText.isNotEmpty) {
      double textScore = 0.0;
      for (String text in detectedText) {
        if (medicine.imprint.toLowerCase().contains(text.toLowerCase()) ||
            medicine.name.toLowerCase().contains(text.toLowerCase())) {
          textScore += 1.0;
        }
      }
      similarity += (textScore / detectedText.length) * 0.2;
    }

    // 기본 유사도 (5% 가중치)
    similarity += 0.05;

    return similarity.clamp(0.0, 1.0);
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