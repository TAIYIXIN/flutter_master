

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class CustomText extends StatelessWidget {

final String text;
final double size;
final Color color;
final FontWeight weight;


  const CustomText({Key? key, required this.text, required this.size, required this.color, required this.weight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ,
        color: color,
        fontWeight: weight
      ),
    );
  }
}