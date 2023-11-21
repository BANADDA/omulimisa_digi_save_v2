import 'package:flutter/material.dart';

class SocialFundPaymentScreen extends StatefulWidget {
  final int? groupId;
  const SocialFundPaymentScreen({super.key, this.groupId});

  @override
  State<SocialFundPaymentScreen> createState() =>
      _SocialFundPaymentScreenState();
}

class _SocialFundPaymentScreenState extends State<SocialFundPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Fund Payment'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is the Social Fund Payment Screen',
              style: TextStyle(fontSize: 20),
            ),
            // Add your payment-related widgets and logic here
          ],
        ),
      ),
    );
  }
}
