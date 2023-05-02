import 'dart:async';

import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/AudioPlayer/widgets/custom_slider_theme.dart';
import 'package:audio_record_play_prj/Utils/helper_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioPath;

  const AudioPlayerWidget({
    super.key,
    this.audioPath,
  });

  @override
  State<StatefulWidget> createState() {
    return _AudioPlayerWidgetState();
  }
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  final AudioPlayer audioPlayer = AudioPlayer();

  /* Total Duration */
  Duration? totalDuration;
  ValueNotifier<int> currentPosn = ValueNotifier<int>(0);
  double startPosn = 0;
  double endPosn = 0;
  ValueNotifier<PlayerState?> playerState = ValueNotifier(PlayerState.playing);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () async {
      await initAudioPlayer();
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    Future.delayed(Duration.zero, () async {
      await stopAudio();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void backAction() {
    Future.delayed(Duration.zero, () async {
      await stopAudio();
    });
    Navigator.pushReplacementNamed(
        context, RoutingConstants.routeAudioListScreen);
  }

  initAudioPlayer() async {
    await audioLocalPathPlayToggle();
    await audioTotalDuration();
    await getCurrentPos();
    playerStateUpdate();
  }

  Future<void> audioTotalDuration() async {
    try {
      totalDuration = await audioPlayer.getDuration();
      print(
          "Audio total duration : $totalDuration || ${totalDuration?.inSeconds}");
    } catch (t) {
      print("Audio Player ERROR: $t");
    }
  }

  getCurrentPos() {
    try {
      audioPlayer.onPositionChanged.listen((Duration p) {
        currentPosn.value = p.inSeconds;
        print('Current position: $p');
      });
    } catch (t) {
      print("Audio Player Current Position ERROR: $t");
    }
  }

  Future<void> audioPause() async {
    try {
      await audioPlayer.pause();
    } catch (t) {
      print("Audio Player ERROR: $t");
    }
  }

  Future<void> audioLocalPathPlayToggle() async {
    try {
      await audioPlayer.play(
        DeviceFileSource(
          widget.audioPath ?? "",
        ),
      );
    } catch (t) {
      print("Audio Player ERROR: $t");
    }
  }

  stopAudio() async {
    try {
      if (audioPlayer.state == PlayerState.playing) {
        await audioPlayer.stop();
      }
    } catch (t) {
      print("Audio Player ERROR: $t");
    }
  }

  playerStateUpdate() {
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      print('Current player state: $s');
      playerState.value = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        backAction();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
          width: SizerUtil.width,
          height: SizerUtil.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: ColorConstants.blueGradient,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                semanticLabel: "Music",
                size: 52.sp,
                color: Colors.black,
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                widget.audioPath.toString().split("/").last.split(".aac")[0],
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              ValueListenableBuilder(
                valueListenable: playerState,
                builder: (context, _, val) {
                  return IconButton(
                    onPressed: () async {
                      if ((playerState.value == PlayerState.paused) ||
                          (playerState.value == PlayerState.stopped)) {
                        await audioLocalPathPlayToggle();
                      } else if (playerState.value == PlayerState.playing) {
                        await audioPause();
                      } else if (playerState.value == PlayerState.completed) {
                        currentPosn.value = 0;
                        await audioPlayer.seek(const Duration(seconds: 0));
                        await initAudioPlayer();
                      }
                    },
                    icon: Icon(
                      (playerState.value == PlayerState.playing)
                          ? Icons.pause_circle_outline
                          : ((playerState.value == PlayerState.paused) ||
                                  (playerState.value == PlayerState.stopped))
                              ? Icons.play_circle_outline_rounded
                              : (playerState.value == PlayerState.completed)
                                  ? Icons.replay
                                  : Icons.abc,
                      color: Colors.black,
                      size: 42.sp,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 5.h,
              ),
              /* Audio Slider */
              ValueListenableBuilder(
                valueListenable: currentPosn,
                builder: (context, _, val) {
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackShape: CustomTrackShape(),
                        ),
                        child: Slider(
                          thumbColor: Colors.white70,
                          inactiveColor: Colors.white24,
                          activeColor: Colors.white70,
                          value: double.parse(currentPosn.value.toString()),
                          min: 0,
                          max: double.parse(
                              totalDuration?.inSeconds.toString() ?? "0"),
                          // onChangeEnd: (v) async {
                          //   print("onChangeEnd");
                          //   int seekval = v.round();
                          //   print("seekval: $seekval");
                          //   await audioPlayer.seek(Duration(seconds: seekval));
                          //   currentPosn.value = seekval;
                          // },
                          onChanged: (double value) async {
                            int seekval = value.round();
                            await audioPlayer.seek(Duration(seconds: seekval));
                            print("seekval onChanged: $seekval");
                            currentPosn.value = seekval;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            HelperUtil.formatDuration(currentPosn.value),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            HelperUtil.formatDuration(
                                totalDuration?.inSeconds ?? 0),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              /* Audio Slider */
            ],
          ),
        ),
      ),
    );
  }
}
