import '/flutter_flow/flutter_flow_util.dart';
import 'search_widget.dart' show SearchWidget;
import 'package:flutter/material.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  // ✅ 실제 데이터를 담을 필드
  final String name;            // ITEM_NAME
  final String description;     // CHART (성상)
  final String manufacturer;    // ENTP_NAME
  final String etcOtcName;      // ETC_OTC_NAME
  final String className;       // CLASS_NAME
  final String imageUrl;        // 이미지 URL (큰제품이미지)
  final String color;           // 색상앞
  final String imprint;         // 표시앞
  final String drugShape;       // 의약품제형
  final String appearance;      // 제형코드명
  final List<String> type;      // 지금은 미사용, 추후 활용 가능

  // ✅ 생성자
  SearchModel({
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.etcOtcName,
    required this.className,
    required this.imageUrl,
    required this.color,
    required this.imprint,
    required this.drugShape,
    required this.appearance,
    required this.type,
  });

  // ✅ JSON → 객체로 변환하는 factory
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      name: json['ITEM_NAME'] ?? '',
      description: json['CHART'] ?? '',
      manufacturer: json['ENTP_NAME'] ?? '',
      etcOtcName: json['ETC_OTC_NAME'] ?? '',
      className: json['CLASS_NAME'] ?? '',
      imageUrl: json['ITEM_IMAGE'] ?? '',
      color: json['COLOR_CLASS1'] ?? '',
      imprint: json['PRINT_FRONT'] ?? '',
      drugShape: json['DRUG_SHAPE'] ?? '',
      appearance: json['CHART'] ?? '',  // 성상 그대로 사용
      type: [], // 향후 다중 분류용으로 사용 가능
    );
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

