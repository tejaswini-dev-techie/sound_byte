import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AudioWaveNoAnimation extends StatelessWidget {
  AudioWaveNoAnimation({Key? key}) : super(key: key);

  final List<double> height = [
    12,
    5,
    34,
    15,
    26,
    8,
    15,
    7,
    30,
    12,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        20,
        (index) {
          return Container(
            width: 1.w,
            height: height[index % 6],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ColorConstants.darkBlueGradient,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          );
        },
      ),
    );
  }
}
