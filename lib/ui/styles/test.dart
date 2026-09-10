import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        height: 1117,
        // decoration: BoxDecoration(
        //   borderRadius : BorderRadius.only(
        //     topLeft: Radius.circular(30),
        //     topRight: Radius.circular(30),
        //     bottomLeft: Radius.circular(30),
        //     bottomRight: Radius.circular(30),
        //   ),
        //   color : Color.fromRGBO(248, 248, 248, 1),
        // ),
        child: Stack(children: <Widget>[
          Container(
              width: Get.width,
              height: 197,
              decoration: BoxDecoration(
                color: Color.fromRGBO(2, 62, 138, 1),
              )),
          Positioned(
              top: 201,
              left: 18,
              child: Container(
                  width: Get.width,
                  height: 439,
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                            width: Get.width,
                            height: 439,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(17.5),
                                topRight: Radius.circular(17.5),
                                bottomLeft: Radius.circular(17.5),
                                bottomRight: Radius.circular(17.5),
                              ),
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ))),
                  ]))),
          Positioned(
              top: 215,
              left: 207,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 59,
                        left: 57,
                        child: Text(
                          'New',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 12,
                        left: 50,
                        child: Container(
                            width: 48,
                            height: 41,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/Newcar2.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 215,
              left: 37,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 58,
                        left: 34,
                        child: Text(
                          'At Terminal',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 8,
                        left: 50,
                        child: Container(
                            width: 48,
                            height: 44,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/Freight1.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 322,
              left: 37,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 62,
                        left: 45,
                        child: Text(
                          'Booked',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 10,
                        left: 50,
                        child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/Rental1.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 322,
              left: 207,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 63,
                        left: 46,
                        child: Text(
                          'Loaded',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 12,
                        left: 51,
                        child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/Port1.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 429,
              left: 207,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 60,
                        left: 39,
                        child: Text(
                          'Delivered',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 5,
                        left: 28,
                        child: Container(
                            width: 91,
                            height: 59,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/Doublecheck1.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 429,
              left: 37,
              child: Container(
                  width: 147,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 62,
                        left: 43,
                        child: Text(
                          'Shipped',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 0,
                        left: 39,
                        child: Container(
                            width: 74,
                            height: 62,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/Cargoship21.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 536,
              left: 37,
              child: Container(
                  width: 317,
                  height: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ],
                    color: Color.fromRGBO(2, 62, 138, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 4,
                        left: 216,
                        child: Container(
                            width: 75,
                            height: 83,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/delivered.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                    Positioned(
                        top: 12,
                        left: 56,
                        child: Text(
                          'Released  to client',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Urbanist',
                              fontSize: 32,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                  ]))),
          Positioned(top: 1049, left: 0, child: Container()),
          Positioned(
              top: 127,
              left: 22,
              child: Text(
                'Mr. Karam Alsharq',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'ABeeZee',
                    fontSize: 20,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          Positioned(
              top: 89,
              left: 22,
              child: Text(
                'Welcome Back !',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Urbanist',
                    fontSize: 32,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          Positioned(
              top: 695,
              left: 11,
              child: Container(
                  width: 368,
                  height: 151,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color:
                              Color.fromRGBO(100, 52, 248, 0.07000000029802322),
                          offset: Offset(0, 180.43280029296875),
                          blurRadius: 144.3462371826172)
                    ],
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 11,
                        left: 21,
                        child: Text(
                          'Vehicle ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 78,
                        left: 21,
                        child: Text(
                          'Comment',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(top: 0, left: 311, child: Container()),
                    Positioned(
                        top: 98.6962890625,
                        left: 16,
                        child: Container(
                            width: 168,
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    offset: Offset(0, 4),
                                    blurRadius: 4)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                              border: Border.all(
                                color: Color.fromRGBO(204, 204, 204, 1),
                                width: 1,
                              ),
                            ),
                            child: Stack(children: <Widget>[
                              Positioned(
                                  top: 8.5,
                                  left: 11.230414390563965,
                                  child: Text(
                                    'Your comment here',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(126, 126, 126, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                            ]))),
                    Positioned(
                        top: 35,
                        left: 16,
                        child: Container(
                            width: 171,
                            height: 29,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                                bottomLeft: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    offset: Offset(0, 4),
                                    blurRadius: 4)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Stack(children: <Widget>[
                              Positioned(
                                  top: 8,
                                  left: 45,
                                  child: Text(
                                    'Kia Optima 2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                            ]))),
                    Positioned(
                        top: 39,
                        left: 227,
                        child: Container(
                            width: 73,
                            height: 73,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    offset: Offset(0, 4),
                                    blurRadius: 4)
                              ],
                              image: DecorationImage(
                                  image: AssetImage('assets/images/File1.png'),
                                  fit: BoxFit.fitWidth),
                            ))),
                  ]))),
          Positioned(
              top: 659,
              left: 29,
              child: Text(
                'Pickup Requests',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(107, 107, 107, 1),
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          Positioned(
              top: 91,
              left: 288,
              child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(61),
                      topRight: Radius.circular(61),
                      bottomLeft: Radius.circular(61),
                      bottomRight: Radius.circular(61),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(
                              173, 232, 244, 0.07000000029802322),
                          offset: Offset(0, 100),
                          blurRadius: 80)
                    ],
                    color: Color.fromRGBO(255, 255, 255, 1),
                    border: Border.all(
                      color: Color.fromRGBO(217, 217, 217, 1),
                      width: 2,
                    ),
                    image: DecorationImage(
                        image: AssetImage('assets/images/logo.jpg'),
                        fit: BoxFit.fitWidth),
                  ),
                  child: Stack(children: <Widget>[]))),
          Positioned(
              top: 149,
              left: 337,
              child: Container(
                  width: 23,
                  height: 25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/Edit1.png'),
                        fit: BoxFit.fitWidth),
                  ))),
          Positioned(
              top: 1066,
              left: 318,
              child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/Financial11.png'),
                        fit: BoxFit.fitWidth),
                  ))),
          Positioned(
              top: 871,
              left: 27,
              child: Container(
                  width: 336,
                  height: 169,
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 27,
                        left: 0,
                        child: Container(
                            width: 336,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                                bottomLeft: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(
                                        25, 74, 249, 0.07000000029802322),
                                    offset: Offset(0, 125.95059967041016),
                                    blurRadius: 100.76048278808594)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Stack(children: <Widget>[
                              Positioned(
                                  top: 14,
                                  left: 84,
                                  child: Text(
                                    'Kia Optima 2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 21,
                                  child: Text(
                                    '6574',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 197,
                                  child: Text(
                                    '2,12,2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 12,
                                  left: 269,
                                  child: Text(
                                    'Waiting',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 203, 70, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                            ]))),
                    Positioned(
                        top: 127,
                        left: 0,
                        child: Container(
                            width: 336,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                                bottomLeft: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(
                                        25, 74, 249, 0.07000000029802322),
                                    offset: Offset(0, 125.95059967041016),
                                    blurRadius: 100.76048278808594)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Stack(children: <Widget>[
                              Positioned(
                                  top: 14,
                                  left: 84,
                                  child: Text(
                                    'Kia Optima 2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 21,
                                  child: Text(
                                    '6574',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 197,
                                  child: Text(
                                    '2,12,2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 12,
                                  left: 268,
                                  child: Text(
                                    'Rejected',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(250, 57, 57, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                            ]))),
                    Positioned(
                        top: 77,
                        left: 0,
                        child: Container(
                            width: 336,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                                bottomLeft: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(
                                        25, 74, 249, 0.07000000029802322),
                                    offset: Offset(0, 125.95059967041016),
                                    blurRadius: 100.76048278808594)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Stack(children: <Widget>[
                              Positioned(
                                  top: 14,
                                  left: 84,
                                  child: Text(
                                    'Kia Optima 2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 21,
                                  child: Text(
                                    '6574',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 14,
                                  left: 197,
                                  child: Text(
                                    '2,12,2020',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(14, 14, 14, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                              Positioned(
                                  top: 12,
                                  left: 261,
                                  child: Text(
                                    'Approved',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Color.fromRGBO(70, 255, 132, 1),
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        letterSpacing:
                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  )),
                            ]))),
                    Positioned(
                        top: 0,
                        left: 94,
                        child: Text(
                          'Vehicle',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 0,
                        left: 22,
                        child: Text(
                          'No.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 0,
                        left: 201,
                        child: Text(
                          'Date',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                    Positioned(
                        top: 1,
                        left: 278,
                        child: Text(
                          'Status',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )),
                  ]))),
        ]));
  }
}
