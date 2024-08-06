import 'package:flutter/material.dart';

class CustomFabLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const CustomFabLocation({this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16.0;
    final double fabY = scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height -
        16.0 -
        offsetY;
    return Offset(fabX, fabY);
  }
}
