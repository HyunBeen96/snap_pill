import '/flutter_flow/flutter_flow_util.dart';
import 'search_widget.dart' show SearchWidget;
import 'package:flutter/material.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  // 실제 데이터를 담을 필드들
  final String name;            // name
  final String description;     // description
  final String manufacturer;    // manufacturer
  final String etcOtcName;      // etcOtcName
  final String className;       // className
  final String imageUrl;        // imageUrl
  final String color;           // color
  final String imprint;         // imprint
  final String drugShape;       // drugShape
  final String appearance;      // appearance
  final List<String> type;      // 추후 확장용

  // 생성자
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

  // JSON → 객체로 변환하는 factory (null 안전 처리 추가)
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      etcOtcName: json['etcOtcName']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      imprint: json['imprint']?.toString() ?? '',
      drugShape: json['drugShape']?.toString() ?? '',
      appearance: json['appearance']?.toString() ?? '',
      type: [], // 향후 다중 분류용으로 사용 가능
    );
  }

  // 디버깅용 toString 메소드
  @override
  String toString() {
    return 'SearchModel{name: $name, manufacturer: $manufacturer, drugShape: $drugShape, color: $color}';
  }

  // 복사 생성자 (필요시 사용)
  SearchModel copyWith({
    String? name,
    String? description,
    String? manufacturer,
    String? etcOtcName,
    String? className,
    String? imageUrl,
    String? color,
    String? imprint,
    String? drugShape,
    String? appearance,
    List<String>? type,
  }) {
    return SearchModel(
      name: name ?? this.name,
      description: description ?? this.description,
      manufacturer: manufacturer ?? this.manufacturer,
      etcOtcName: etcOtcName ?? this.etcOtcName,
      className: className ?? this.className,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      imprint: imprint ?? this.imprint,
      drugShape: drugShape ?? this.drugShape,
      appearance: appearance ?? this.appearance,
      type: type ?? this.type,
    );
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}