import 'package:flutter/material.dart';

import 'color_resources.dart';
import 'dimensions.dart';
import 'styles.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String btnTxt;
  final bool isShowBorder;
  final bool isBoldText;
  final bool hasIcon;
  final Color textColor;
  final Widget? widget;
  final bool hasLoader;
  final double width;
  final double height;
  final bool hasArrow;
  final bool isBold;
  final bool isCustomFont;
  final double? textFont;
  final double borderRadius;
  final bool isLoader;
  final Color buttonColor;
  final Color borderColor;
  final double fontSize;

  const CustomButton({super.key, 
    required this.onTap,
    this.btnTxt = "",
    this.isShowBorder = false,
    this.isBoldText = false,
    this.hasIcon = false,
    this.textColor = Colors.white,
    this.widget,
    this.hasLoader = false,
    this.height = 50,
    this.width = double.infinity,
    this.hasArrow = false,
    this.isBold = false,
    this.isCustomFont = false,
    this.textFont,
    this.borderRadius = 10,
    this.isLoader = false,
    this.buttonColor = Colors.grey,
    this.fontSize = 16,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: !isShowBorder
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 1))
          ],
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isShowBorder
                ? borderColor == Colors.black
                    ? ColorResources.getPrimaryColor(context)
                    : borderColor
                : Colors.transparent,
            width: 1.5,
          ),
          color: !isShowBorder ? buttonColor : Colors.transparent,
        ),
        child: Text(
          btnTxt,
          style: isBold
              ? urbanistBlack.copyWith(
                  color: textColor,
                  fontSize:
                      isCustomFont ? textFont : Dimensions.fontSizeDefault,
                )
              : urbanistMedium.copyWith(
                  color: textColor,
                  fontSize:
                      isCustomFont ? textFont : Dimensions.fontSizeDefault,
                ),
        ),
      ),
    );
  }
}
