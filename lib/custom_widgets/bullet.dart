import 'package:flutter/material.dart';


class Bullet extends StatelessWidget {
  final String text;
  TextStyle? style;
  Bullet(this.text,{this.style});
  

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• ",style: style,),
        Expanded(
          child: Text(text,style: style,),
        ),
      ],
    );
  }
}