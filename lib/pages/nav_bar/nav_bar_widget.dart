import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nav_bar_model.dart';
export 'nav_bar_model.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  late NavBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 76.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(26.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 20.0,
              buttonSize: 60.0,
              icon: Icon(
                FFIcons.khouse01,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              onPressed: () async {
                context.pushNamed(HomePageWidget.routeName);
              },
            ),
            Stack(
              alignment: AlignmentDirectional(0.0, 0.0),
              children: [
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20.0,
                  buttonSize: 60.0,
                  icon: Icon(
                    Icons.alarm,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.pushNamed(PillAlarmWidget.routeName);
                  },
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 24.0),
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      shape: BoxShape.circle,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        '2',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).info,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 20.0,
              buttonSize: 60.0,
              icon: FaIcon(
                FontAwesomeIcons.pills,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              onPressed: () async {
                context.pushNamed(PilldataWidget.routeName);
              },
            ),
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 20.0,
              buttonSize: 60.0,
              icon: FaIcon(
                FontAwesomeIcons.mapMarkerAlt,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              onPressed: () async {
                context.pushNamed(MapWidget.routeName);
              },
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 50.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.warning_rounded,
                  color: Color(0xFF6E7DA2),
                  size: 24.0,
                ),
                onPressed: () async {
                  context.pushNamed(HomePageWidget.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
