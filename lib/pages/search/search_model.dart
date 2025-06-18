import '/flutter_flow/flutter_flow_util.dart';
import 'search_widget.dart' show SearchWidget;
import 'package:flutter/material.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  // ✅ 실제 데이터를 담을 필드 추가
  final String name;
  final String description;
  final String manufacturer;
  final String etcOtcName;
  final String className;
  final List<String> type;

  // ✅ 생성자
  SearchModel({
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.type,
    required this.etcOtcName,    // ✅ 추가
    required this.className,     // ✅ 추가
  });

  // ✅ JSON → 객체로 변환하는 factory 생성자
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      name: json['itemName'] ?? '',
      description: json['efcyQesitm'] ?? '',
      manufacturer: json['entpName'] ?? '',
      type: [], // 필요 시 가공
      etcOtcName: json['etcOtcName'] ?? '',
      className: json['className'] ?? '',
    );
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}


