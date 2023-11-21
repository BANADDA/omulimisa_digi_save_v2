import 'package:flutter/material.dart';

import 'custom/custom_button.dart';
import 'image_data.dart';

class TopCard extends StatefulWidget {
  const TopCard({super.key});

  @override
  State<TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
  bool hide = false;

  showhide() {
    setState(() {
      hide = !hide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showhide();
                  },
                  child: Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Image.asset(
                          hide == false ? Images.hide : Images.show,
                          width: 15,
                          height: 15,
                        ),
                      )),
                )
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                showhide();
              },
              child: Text(
                hide == false ? 'UGX 2,000,000' : 'Tap to show',
                style: TextStyle(
                    fontSize: hide == false ? 16 + 4 : 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Align buttons in a row
              children: [
                CustomButton(
                  onTap: () {},
                  btnTxt: 'Fund Wallet',
                  width: MediaQuery.of(context).size.width * .38,
                  buttonColor: Colors.green,
                  textColor: Colors.white,
                ),
                CustomButton(
                  onTap: () {},
                  btnTxt: 'Withdraw',
                  width: MediaQuery.of(context).size.width * .38,
                  buttonColor: Colors.green,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  isShowBorder: true,
                ),
              ],
            ),
          ]),
    );
  }
}
