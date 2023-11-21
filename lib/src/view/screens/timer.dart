import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class OfflineBuilder extends StatefulWidget {
  final ConnectivityResult connectivity;
  final Widget child;

  const OfflineBuilder({
    Key? key,
    required this.connectivity,
    required this.child,
  }) : super(key: key);

  @override
  _OfflineBuilderState createState() => _OfflineBuilderState();
}

class _OfflineBuilderState extends State<OfflineBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.connectivity != ConnectivityResult.none) {
      // Start the timer to send the offline text every after 10 seconds.
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        // Send the offline text.
      });
    }
  }

  @override
  void dispose() {
    // Cancel the timer.
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.connectivity != ConnectivityResult.none
        ? widget.child
        : Center(
            child: Text('OFFLINE'),
          );
  }
}
