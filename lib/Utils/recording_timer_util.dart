import 'dart:async';

import 'package:audio_record_play_prj/Utils/helper_util.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TimeController extends ValueNotifier<bool> {
  TimeController({bool isPlaying = false}) : super(isPlaying);
  void startTimer() => value = true;
  void stopTimer() => value = false;
  Duration timeValue = Duration.zero;
}

class RecordingTimerUtil extends StatefulWidget {
  final TimeController timeController;
  final int maxTime;
  // ignore: prefer_typing_uninitialized_variables
  final audioRecording;
  const RecordingTimerUtil({
    Key? key,
    required this.timeController,
    required this.maxTime,
    this.audioRecording,
  }) : super(key: key);

  @override
  State<RecordingTimerUtil> createState() => _RecordingTimerUtilState();
}

class _RecordingTimerUtilState extends State<RecordingTimerUtil> {
  Duration duration = const Duration();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    widget.timeController.addListener(() {
      if (widget.timeController.value) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void reset() => setState(() {
        duration = const Duration();
      });

  void addTime() {
    print("Add Time");
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0 || seconds >= widget.maxTime) {
        timer?.cancel();
        widget.audioRecording();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer({bool resets = true}) {
    print("startTimer Time");
    if (!mounted) return;
    if (resets) {
      reset();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    print("stopTimer Time");
    if (!mounted) return;
    widget.timeController.timeValue = duration;
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  void cancelTimer() {
    if (timer != null) {
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      HelperUtil.formatDuration(
        (timer?.tick == null) ? 00 : timer!.tick,
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
