
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> searchPillsByCondition({
  required String serviceKey,
  String? itemName,
  String? chart,
  String? printFront,
  String? printBack,
  String? drugShape,
  String? colorClass1,
  String? colorClass2,
  int pageNo = 1,
  int numOfRows = 20,
}) async {
  final uri = Uri.parse(
    'https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getMdctinGrnIdntfcInfoList02'
    '?serviceKey=$serviceKey'
    '&type=json'
    '&pageNo=$pageNo'
    '&numOfRows=$numOfRows'
    '${itemName != null ? '&item_name=\$itemName' : ''}'
    '${chart != null ? '&chart=\$chart' : ''}'
    '${printFront != null ? '&print_front=\$printFront' : ''}'
    '${printBack != null ? '&print_back=\$printBack' : ''}'
    '${drugShape != null ? '&drug_shape=\$drugShape' : ''}'
    '${colorClass1 != null ? '&color_class1=\$colorClass1' : ''}'
    '${colorClass2 != null ? '&color_class2=\$colorClass2' : ''}',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['body']['items'] ?? [];
  } else {
    throw Exception('Failed to load pill data');
  }
}
