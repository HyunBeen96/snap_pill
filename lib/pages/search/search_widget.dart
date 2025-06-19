import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'search_model.dart';
export 'search_model.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


class SearchWidget extends StatefulWidget {
  final String searchKeyword; // ✅ 이 줄 추가
  const SearchWidget({Key? key, required this.searchKeyword}) : super(key: key);

  static String routeName = 'search';
  static String routePath = '/search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  Future<List<SearchModel>> loadJsonAsset() async {
    final jsonStr = await rootBundle.loadString('assets/tablet_data_final.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    final List<SearchModel> items = jsonData
        .map((item) => SearchModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return items;
  }

  List<SearchModel> searchResults = [];
  TextEditingController _searchController = TextEditingController(); // 검색창 연결용
  List<SearchModel> results = [];
  late SearchModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();


  Future<List<SearchModel>> loadSearchData(BuildContext context) async {
    final String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/json/tablet_data_final.json');

    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList
        .map((jsonItem) => SearchModel.fromJson(jsonItem))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  void loadJson() async {
    final data = await loadJsonAsset();
    setState(() {
      searchItems = data;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
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
            '의약품 검색 결과',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
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
          top: true,
          child: FutureBuilder(
            future: fetchSearchResults(widget.searchKeyword),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return Center(child: Text('검색 결과가 없습니다'));
              }

              final results = snapshot.data as List<SearchModel>;

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Color(0xFFE0E3E7), width: 1.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 좌측 아이콘
                            Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.medication,
                                  color: Color(0xFF9489F5),
                                  size: 32.0,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            // 텍스트 + 버튼
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: Color(0xFF57636C),
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    item.description,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.manrope(),
                                      color: Color(0xFF57636C),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE3F2FD),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            item.etcOtcName,
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              color: Color(0xFF9489F5),
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF3E5F5),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            item.className,
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              color: Color(0xFF7B1FA2),
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    '제조사: ${item.manufacturer}',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.manrope(),
                                      color: Color(0xFF57636C),
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 22.0,
                              buttonSize: 44.0,
                              fillColor: Color(0xFF9489F5),
                              icon: Icon(Icons.add, color: Colors.white, size: 20.0),
                              onPressed: () {
                                print('추가 버튼 눌림: ${item.name}');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


class SearchResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String manufacturer;
  final List<String> typeTags;

  const SearchResultTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.manufacturer,
    required this.typeTags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FlutterFlowTheme.of(context).headlineSmall),
          SizedBox(height: 4),
          Text(subtitle, style: FlutterFlowTheme.of(context).bodyMedium),
          SizedBox(height: 4),
          Text('제조사: $manufacturer', style: FlutterFlowTheme.of(context).bodySmall),
          SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            children: typeTags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () {
                // 여기에 나중에 '내 약에 등록하기' 기능 넣을 수 있어
              },
            ),
          ),
        ],
      ),
    );
  }
}
