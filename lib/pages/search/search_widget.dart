import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'search_model.dart';
export 'search_model.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SearchWidget extends StatefulWidget {
  final String searchKeyword;
  final List<String>? selectedShapes;
  final List<String>? selectedFormTypes;
  final List<String>? selectedColors;
  final String? frontText;
  final String? backText;
  final bool isImageSearch;
  final String? capturedImagePath;
  final Map<String, dynamic>? analysisResult;
  final List<SearchModel>? similarMedicines;

  const SearchWidget({
    Key? key,
    required this.searchKeyword,
    this.selectedShapes,
    this.selectedFormTypes,
    this.selectedColors,
    this.frontText,
    this.backText,
    this.isImageSearch = false,
    this.capturedImagePath,
    this.analysisResult,
    this.similarMedicines,
  }) : super(key: key);

  static String routeName = 'search';
  static String routePath = '/search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<SearchModel> allMedicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 이미지 검색이고 이미 결과가 있으면 로딩 스킵
    if (widget.isImageSearch && widget.similarMedicines != null) {
      setState(() {
        allMedicines = widget.similarMedicines!;
        isLoading = false;
      });
    } else {
      loadMedicineData();
    }
  }

  Future<void> loadMedicineData() async {
    print('🔥 JSON 로딩 시작!');

    try {
      String jsonStr = await rootBundle.loadString('assets/tablet_data_final.json');
      print('✅ JSON 파일 읽기 성공: ${jsonStr.length} 글자');

      // NaN 값들을 null로 바꾸기
      jsonStr = jsonStr.replaceAll(': NaN,', ': null,');
      jsonStr = jsonStr.replaceAll(': NaN}', ': null}');
      jsonStr = jsonStr.replaceAll(': undefined,', ': null,');
      jsonStr = jsonStr.replaceAll(': undefined}', ': null}');

      List<dynamic> jsonData = json.decode(jsonStr);
      print('✅ JSON 파싱 성공: ${jsonData.length}개 아이템');

      List<SearchModel> medicines = [];
      for (var item in jsonData) {
        try {
          if (item != null && item is Map<String, dynamic>) {
            medicines.add(SearchModel.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          // 개별 아이템 오류는 무시하고 계속
        }
      }

      setState(() {
        allMedicines = medicines;
        isLoading = false;
      });

      print('🎉 로딩 완료! 총 ${allMedicines.length}개 의약품');

    } catch (e) {
      print('❌ 로딩 실패: $e');
      setState(() {
        allMedicines = [];
        isLoading = false;
      });
    }
  }

  List<SearchModel> getFilteredResults() {
    // 이미지 검색이고 이미 결과가 있으면 그대로 반환
    if (widget.isImageSearch && widget.similarMedicines != null) {
      return widget.similarMedicines!;
    }

    if (allMedicines.isEmpty) {
      return [];
    }

    // 이미지 검색인 경우 다른 로직 적용
    if (widget.isImageSearch) {
      return getImageSearchResults();
    }

    // 기존 텍스트 검색 로직
    List<SearchModel> results = allMedicines.where((medicine) {
      if (widget.searchKeyword.isNotEmpty) {
        bool nameMatch = medicine.name.toLowerCase().contains(widget.searchKeyword.toLowerCase());
        if (!nameMatch) return false;
      }

      if (widget.selectedShapes != null && widget.selectedShapes!.isNotEmpty) {
        bool shapeMatch = widget.selectedShapes!.any((shape) =>
            medicine.drugShape.toLowerCase().contains(shape.toLowerCase()));
        if (!shapeMatch) return false;
      }

      if (widget.selectedFormTypes != null && widget.selectedFormTypes!.isNotEmpty) {
        bool formMatch = widget.selectedFormTypes!.any((formType) =>
        medicine.className.toLowerCase().contains(formType.toLowerCase()) ||
            medicine.appearance.toLowerCase().contains(formType.toLowerCase()));
        if (!formMatch) return false;
      }

      if (widget.selectedColors != null && widget.selectedColors!.isNotEmpty) {
        bool colorMatch = widget.selectedColors!.any((color) =>
            medicine.color.toLowerCase().contains(color.toLowerCase()));
        if (!colorMatch) return false;
      }

      if (widget.frontText != null && widget.frontText!.isNotEmpty) {
        bool frontMatch = medicine.imprint.toLowerCase().contains(widget.frontText!.toLowerCase());
        if (!frontMatch) return false;
      }

      return true;
    }).toList();

    return results;
  }

  // 이미지 검색 결과 생성 (현재는 시뮬레이션)
  List<SearchModel> getImageSearchResults() {
    List<SearchModel> results = [];

    // 원형 약물들을 우선적으로 표시 (예시)
    var circularMedicines = allMedicines.where((medicine) =>
    medicine.drugShape.toLowerCase().contains('원형') ||
        medicine.drugShape.toLowerCase().contains('circle')).toList();

    results.addAll(circularMedicines.take(5));

    // 부족하면 다른 약물들도 추가
    if (results.length < 10) {
      var otherMedicines = allMedicines.where((medicine) =>
      !results.contains(medicine)).take(10 - results.length);
      results.addAll(otherMedicines);
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF1F4F8),
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F4F8),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Color(0xFF101213),
              size: 24.0,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.isImageSearch ? '이미지 검색 결과' : '의약품 검색 결과',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
              ),
              color: Color(0xFF101213),
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: isLoading ? _buildLoadingView() : _buildResultsView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            widget.isImageSearch ? '이미지를 분석하고 있습니다...' : '의약품 데이터 로딩 중...',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final results = getFilteredResults();

    if (results.isEmpty) {
      return _buildEmptyResults();
    }

    return Column(
      children: [
        // 이미지 검색인 경우 분석 결과 표시
        if (widget.isImageSearch && widget.analysisResult != null)
          _buildAnalysisResultCard(),

        // 촬영된 이미지 표시
        if (widget.isImageSearch && widget.capturedImagePath != null)
          _buildCapturedImageCard(),

        // 검색 결과 개수 표시
        _buildResultsHeader(results.length),

        // 검색 결과 리스트
        Expanded(
          child: _buildResultsList(results),
        ),
      ],
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            widget.isImageSearch ? '유사한 약물을 찾을 수 없습니다' : '검색 결과가 없습니다',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.isImageSearch ? '다른 각도에서 다시 촬영해보세요' : '다른 검색어를 시도해보세요',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard() {
    final analysis = widget.analysisResult!;

    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade700, size: 20),
              SizedBox(width: 8),
              Text(
                '이미지 분석 결과',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '신뢰도 ${((analysis['confidence'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if ((analysis['colors'] as List).isNotEmpty)
                _buildAnalysisChip('색상', (analysis['colors'] as List).join(', '), Colors.purple),
              if (analysis['shape'] != '알 수 없음')
                _buildAnalysisChip('모양', analysis['shape'], Colors.orange),
              if ((analysis['text'] as List).isNotEmpty)
                _buildAnalysisChip('텍스트', (analysis['text'] as List).join(', '), Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImageCard() {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(widget.capturedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '촬영된 약물',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '유사한 약물을 찾았습니다',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '검색 결과: ${count}개',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontWeight: FontWeight.w600,
              color: Color(0xFF57636C),
            ),
          ),
          if (widget.isImageSearch)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '이미지 검색',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchModel> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Color(0xFFE0E3E7), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 좌측 이미지 또는 아이콘
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medication,
                            color: Color(0xFF9489F5),
                            size: 32.0,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.medication,
                      color: Color(0xFF9489F5),
                      size: 32.0,
                    ),
                  ),

                  SizedBox(width: 12.0),

                  // 텍스트 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                                  color: Color(0xFF101213),
                                  fontSize: 16.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 이미지 검색인 경우 유사도 표시 (시뮬레이션)
                            if (widget.isImageSearch)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getSimilarityColor(index),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_getSimilarityScore(index)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 4.0),

                        Text(
                          item.description,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: Color(0xFF57636C),
                            fontSize: 12.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 8.0),

                        // 태그들
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: [
                            if (item.etcOtcName.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  item.etcOtcName,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    color: Color(0xFF1976D2),
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                            if (item.className.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  item.className,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    color: Color(0xFF7B1FA2),
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                            if (item.drugShape.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  item.drugShape,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 6.0),

                        // 제조사 정보
                        Text(
                          '제조사: ${item.manufacturer}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: Color(0xFF57636C),
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 추가 버튼
                  FlutterFlowIconButton(
                    borderRadius: 22.0,
                    buttonSize: 44.0,
                    fillColor: Color(0xFF9489F5),
                    icon: Icon(Icons.add, color: Colors.white, size: 20.0),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('내 약에 추가'),
                            content: Text('${item.name}을(를) 내 약 목록에 추가하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name}이(가) 내 약 목록에 추가되었습니다.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: Text('추가'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 유사도 점수 계산 (시뮬레이션)
  int _getSimilarityScore(int index) {
    if (index == 0) return 95;
    if (index == 1) return 88;
    if (index == 2) return 82;
    if (index < 5) return 75 - (index * 2);
    return 65 - (index * 1);
  }

  // 유사도에 따른 색상 반환
  Color _getSimilarityColor(int index) {
    int score = _getSimilarityScore(index);
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red.shade300;
  }
}