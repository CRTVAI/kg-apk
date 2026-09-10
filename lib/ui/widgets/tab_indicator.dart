import 'package:flutter/material.dart';

class TabIndicator extends Decoration {
  final Color color;
  final double radious;

  TabIndicator({required this.color, required this.radious});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _Circlepainter(color: color, radious: radious);
  }
}

class _Circlepainter extends BoxPainter {
  final double radious;
  late Color color;

  _Circlepainter({required this.radious, required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration conf) {
    late Paint _paint;
    _paint = Paint()..color = color;
    _paint = _paint..isAntiAlias = true;
    // final Offset circleOffset = offset + Offset(conf.size!.width/2);
    // TODO: implement paint
  }
}
