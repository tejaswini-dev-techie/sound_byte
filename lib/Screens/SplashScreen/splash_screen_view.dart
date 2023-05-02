import 'dart:async';

import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:audio_record_play_prj/Constants/string_constants.dart';
import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/RecordScreen/record_audio_view.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacementNamed(
        RoutingConstants.routeRecordAudio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: SizerUtil.width,
        height: SizerUtil.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: ColorConstants.blueGradient,
          ),
        ),
        child: Center(
          child: Text(
            StringConstants.appTitleText,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
