import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final VoidCallback onTab;
  final IconData iconData;

  CustomButton(this.iconData,this.onTab);
  @override
  Widget build(BuildContext context) {
    return new IconButton(
      onPressed: onTab,
      iconSize: 50.0,
      icon: new Icon(iconData),
      color: Colors.white,
    );
  }
}