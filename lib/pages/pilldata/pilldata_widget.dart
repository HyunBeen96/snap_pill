import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pages/snap/snap_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pilldata_model.dart';
export 'pilldata_model.dart';

class PilldataWidget extends StatefulWidget {
  const PilldataWidget({super.key});

  static String routeName = 'pilldata';
  static String routePath = '/pilldata';

  @override
  State<PilldataWidget> createState() => _PilldataWidgetState();
}

class _PilldataWidgetState extends State<PilldataWidget> {
  late PilldataModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // 다중 선택을 위한 변수들
  List<String> selectedColors = [];
  List<String> selectedFormTypes = [];
  List<String> selectedShapes = [];

  // 색상 데이터 맵핑
  final Map<String, Color> colorMap = {
    '하양': Colors.white,
    '투명': Colors.transparent,
    '분홍': Color(0xFFFFC0CB),
    '빨강': Color(0xFFFF0000),
    '자주': Color(0xFF800080),
    '노랑': Color(0xFFFFFF00),
    '주황': Color(0xFFFFA500),
    '연두': Color(0xFF90EE90),
    '초록': Color(0xFF008000),
    '청록': Color(0xFF40E0D0),
    '파랑': Color(0xFF0000FF),
    '남색': Color(0xFF000080),
    '보라': Color(0xFF8A2BE2),
    '갈색': Color(0xFFA52A2A),
    '회색': Color(0xFF808080),
    '검정': Colors.black,
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PilldataModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // 색상 선택/해제 토글 함수
  void toggleColorSelection(String colorName) {
    setState(() {
      if (selectedColors.contains(colorName)) {
        selectedColors.remove(colorName);
      } else {
        selectedColors.add(colorName);
      }
    });
  }

  // 제형 선택/해제 토글 함수
  void toggleFormTypeSelection(String formType) {
    setState(() {
      if (selectedFormTypes.contains(formType)) {
        selectedFormTypes.remove(formType);
      } else {
        selectedFormTypes.add(formType);
      }
    });
  }

  // 모양 선택/해제 토글 함수
  void toggleShapeSelection(String shape) {
    setState(() {
      if (selectedShapes.contains(shape)) {
        selectedShapes.remove(shape);
      } else {
        selectedShapes.add(shape);
      }
    });
  }

  // 색상 원형 위젯 빌더 (더 작은 크기)
  Widget buildColorCircle(String colorName, Color color) {
    bool isSelected = selectedColors.contains(colorName);

    return Center(  // 셀 중앙에 배치
      child: GestureDetector(
        onTap: () => toggleColorSelection(colorName),
        child: Container(
          width: 40.0,  // 더 작게 조정
          height: 40.0, // 더 작게 조정
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).alternate,
              width: isSelected ? 2.0 : 1.0,  // 테두리도 더 얇게
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ] : null,
          ),
          child: isSelected
              ? Icon(
            Icons.check,
            color: color == Colors.white || color == Colors.transparent
                ? Colors.black
                : Colors.white,
            size: 12,  // 체크 아이콘도 더 작게
          )
              : null,
        ),
      ),
    );
  }

  // 색상 그리드뷰 위젯 (더 조밀하게)
  Widget buildColorGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 4.0,   // 간격 줄임
        mainAxisSpacing: 4.0,    // 간격 줄임
        childAspectRatio: 1.0,
      ),
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: colorMap.length,
      itemBuilder: (context, index) {
        String colorName = colorMap.keys.elementAt(index);
        Color color = colorMap.values.elementAt(index);
        return buildColorCircle(colorName, color);
      },
    );
  }

  // 제형 칩 위젯 빌더
  Widget buildFormTypeChip(String formType) {
    bool isSelected = selectedFormTypes.contains(formType);

    return GestureDetector(
      onTap: () => toggleFormTypeSelection(formType),
      child: Container(
        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          formType,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 모양 칩 위젯 빌더
  Widget buildShapeChip(String shape) {
    bool isSelected = selectedShapes.contains(shape);

    return GestureDetector(
      onTap: () => toggleShapeSelection(shape),
      child: Container(
        margin: EdgeInsets.only(right: 6.0, bottom: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          shape,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 검색 함수
  void performSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchWidget(
          searchKeyword: _model.textController1?.text ?? '',
          selectedShapes: selectedShapes,      // 다중 선택
          selectedFormTypes: selectedFormTypes, // 다중 선택
          selectedColors: selectedColors,
          frontText: _model.textController2?.text ?? '',
          backText: _model.textController3?.text ?? '',
        ),
      ),
    );
  }

  // 필터 초기화 함수
  void clearAllFilters() {
    setState(() {
      _model.textController1?.clear();
      _model.textController2?.clear();
      _model.textController3?.clear();
      selectedFormTypes.clear();
      selectedShapes.clear();
      selectedColors.clear();
    });
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: performSearch,
          backgroundColor: FlutterFlowTheme.of(context).primary,
          icon: Icon(Icons.search, color: Colors.white),
          elevation: 8.0,
          label: Text(
            '검색 하기',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              color: Colors.white,
              fontSize: 20.0,
              letterSpacing: 0.0,
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '약 정보',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              fontSize: 18.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderRadius: 20.0,
              buttonSize: 40.0,
              icon: Icon(
                Icons.refresh,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              onPressed: clearAllFilters,
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Column(
                  children: [
                    // 검색바와 카메라 버튼
                    Stack(
                      children: [
                        TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          decoration: InputDecoration(
                            hintText: '의약품명을 입력하세요',
                            hintStyle: FlutterFlowTheme.of(context).bodyMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                            prefixIcon: Icon(
                              Icons.search,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0,
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 10.0, 0.0),
                            child: InkWell(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      elevation: 0,
                                      insetPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      child: SnapWidget(),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 46.0,
                                height: 46.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFA1ABC0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.0),

                    // 제형 선택 (다중 선택)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '제형 (여러 개 선택 가능)',
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Wrap(
                          children: [
                            buildFormTypeChip('정제'),
                            buildFormTypeChip('경질캡슐'),
                            buildFormTypeChip('연질캡슐'),
                            buildFormTypeChip('필름코팅정'),
                            buildFormTypeChip('당의정'),
                          ],
                        ),
                        if (selectedFormTypes.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 6.0,
                              children: selectedFormTypes.map((type) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    type,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 20.0),

                    // 모양 선택 (다중 선택)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '모양 (여러 개 선택 가능)',
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Wrap(
                          children: [
                            buildShapeChip('원형'),
                            buildShapeChip('타원형'),
                            buildShapeChip('장방형'),
                            buildShapeChip('반원형'),
                            buildShapeChip('마름모'),
                            buildShapeChip('삼각형'),
                            buildShapeChip('사각형'),
                            buildShapeChip('오각형'),
                            buildShapeChip('육각형'),
                            buildShapeChip('팔각형'),
                            buildShapeChip('기타'),
                          ],
                        ),
                        if (selectedShapes.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 6.0,
                              children: selectedShapes.map((shape) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    shape,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 20.0),

                    // 문자 입력
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '문자',
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                decoration: InputDecoration(
                                  hintText: '앞면 문자',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                controller: _model.textController3,
                                focusNode: _model.textFieldFocusNode3,
                                decoration: InputDecoration(
                                  hintText: '뒷면 문자',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20.0),

                    // 색상 선택
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '색상 (여러 개 선택 가능)',
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        buildColorGrid(),
                        if (selectedColors.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 6.0,
                              children: selectedColors.map((color) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    color,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 100.0), // FloatingActionButton 공간
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}