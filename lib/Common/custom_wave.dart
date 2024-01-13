import 'package:flutter/cupertino.dart';

class RPSCustomPainter extends CustomPainter{

  final Color color;

  RPSCustomPainter({required this.color});


  @override
  void paint(Canvas canvas, Size size) {



    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;


    Path path_0 = Path();
    path_0.moveTo(0,0);
    path_0.quadraticBezierTo(size.width*0.1238250,size.height*0.2518143,size.width*0.1676000,size.height*0.2849143);
    path_0.cubicTo(size.width*0.1722750,size.height*0.3147714,size.width*0.6675333,size.height*0.2909607,size.width*0.8350083,size.height*0.2909857);
    path_0.cubicTo(size.width*0.9779333,size.height*0.2953286,size.width*0.9794333,size.height*0.4911429,size.width*1.0002667,size.height*0.5760714);
    path_0.quadraticBezierTo(size.width*0.9999917,size.height*0.4313393,size.width*0.9991667,size.height*-0.0028571);

    canvas.drawPath(path_0, paint_fill_0);


    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;



    canvas.drawPath(path_0, paint_stroke_0);


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

