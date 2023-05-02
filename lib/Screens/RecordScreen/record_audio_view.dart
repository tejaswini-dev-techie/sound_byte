import 'dart:io';

import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:audio_record_play_prj/Constants/string_constants.dart';
import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/RecordScreen/recorder_bloc/recorder_bloc.dart';
import 'package:audio_record_play_prj/Screens/RecordScreen/widgets/permission_req_widget.dart';
import 'package:audio_record_play_prj/Utils/audio_visualiser.dart';
import 'package:audio_record_play_prj/Utils/error_widget.dart';
import 'package:audio_record_play_prj/Utils/gradient_circle_paint.dart';
import 'package:audio_record_play_prj/Utils/recording_timer_util.dart';
import 'package:audio_record_play_prj/Utils/static_audio_waves.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class RecordAudioView extends StatefulWidget {
  const RecordAudioView({super.key});

  @override
  State<RecordAudioView> createState() => _RecordAudioViewState();
}

class _RecordAudioViewState extends State<RecordAudioView>
    with WidgetsBindingObserver {
  /* Bloc Initialisation */
  final RecorderBloc recorderBloc = RecorderBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.storage,
        Permission.microphone,
      ].request();

      if (permissions[Permission.storage]!.isGranted &&
          permissions[Permission.microphone]!.isGranted) {
        recorderBloc.add(LaunchRecorder());
      }
    }

    if (await recorderBloc.audioRecorder.isRecording()) {
      recorderBloc.add(StopRecord());
    }

    if (recorderBloc.audioPlayer.state == PlayerState.playing) {
      await recorderBloc.audioPlayer.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    /* Bloc Dispose */
    recorderBloc.close();
    /* Timer Dispose */
    recorderBloc.timeController?.dispose();
    /* Audio Recorder Dispose */
    recorderBloc.audioRecorder.dispose();
    /* Audio Player Dispose */
    recorderBloc.audioPlayer.dispose();
    super.dispose();
  }

  void backAction() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              StringConstants.exitTitleText,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: Text(
                  StringConstants.noText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // passing true
                child: Text(
                  StringConstants.yesText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }).then((exit) async {
      if (exit == null) return;

      if (exit) {
        // user pressed Yes button
        SystemNavigator.pop();
      } else {
        // user pressed No button
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await recorderBloc.audioRecorder.isRecording()) {
          recorderBloc.add(StopRecord());
        }

        if (recorderBloc.audioPlayer.state == PlayerState.playing) {
          await recorderBloc.audioPlayer.stop();
        }
        backAction();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.4,
          title: Text(
            StringConstants.appTitleText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   onPressed: () => backAction(),
          //   icon: Icon(
          //     Icons.arrow_back_ios,
          //     color: Colors.black,
          //     size: 14.sp,
          //   ),
          // ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                RoutingConstants.routeAudioListScreen,
              ),
              icon: Icon(
                Icons.music_note_sharp,
                color: Colors.black,
                size: 18.sp,
              ),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            child: BlocBuilder<RecorderBloc, RecorderState>(
              bloc: recorderBloc,
              builder: (context, state) {
                if (state is RecorderInitial) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        painter: CircularPaint(
                          progressValue: 100.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            recorderBloc.add(InitRecord());
                            // recorderBloc.timeController?.startTimer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorConstants.lightBlueColor
                                  .withOpacity(0.4),
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: ColorConstants.darkBlueGradient,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            margin: EdgeInsets.all(8.sp),
                            padding: EdgeInsets.all(12.sp),
                            child: Icon(
                              Icons.mic,
                              semanticLabel: "Record",
                              size: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.sp,
                      ),
                      RecordingTimerUtil(
                        timeController: recorderBloc.timeController!,
                        maxTime: 60,
                      ),
                    ],
                  );
                } else if (state is RecorderStart) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: SizerUtil.width * 0.80,
                        // height: 5.h,
                        child: AudioVisualiser(),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          recorderBloc.add(StopRecord());
                          // recorderBloc.timeController?.stopTimer();
                        },
                        child: Icon(
                          Icons.stop_circle,
                          semanticLabel: "Stop Record",
                          size: 55.sp,
                          color: ColorConstants.redColor,
                        ),
                      ),
                      RecordingTimerUtil(
                        timeController: recorderBloc.timeController!,
                        maxTime: 60,
                        audioRecording: () {
                          recorderBloc.add(StopRecord());
                          // recorderBloc.timeController?.stopTimer();
                        },
                      ),
                    ],
                  );
                } else if (state is LocalAudioInit) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              recorderBloc.add(PlayAudio(state.audioPath));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConstants.lightBlueColor
                                    .withOpacity(0.4),
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: ColorConstants.darkBlueGradient,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: EdgeInsets.all(6.sp),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                semanticLabel: "Play",
                                size: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1.5.w,
                          ),
                          SizedBox(
                            width: SizerUtil.width * 0.75,
                            child: AudioWaveNoAnimation(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 8.sp,
                      ),
                      InkWell(
                        onTap: () {
                          recorderBloc.add(LaunchRecorder());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorConstants.skyBlueColor,
                            borderRadius: BorderRadius.circular(4.sp),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.sp,
                            vertical: 6.sp,
                          ),
                          child: Text(
                            StringConstants.recordText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else if (state is PlayRecordedAudio) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              recorderBloc.add(PauseAudio(state.audioPath));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConstants.lightBlueColor
                                    .withOpacity(0.4),
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: ColorConstants.darkBlueGradient,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: EdgeInsets.all(6.sp),
                              child: Icon(
                                Icons.pause,
                                semanticLabel: "Pause",
                                size: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1.5.w,
                          ),
                          SizedBox(
                            width: SizerUtil.width * 0.75,
                            child: AudioVisualiser(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 40.sp,
                      )
                    ],
                  );
                } else if (state is PermissionRequest) {
                  return PermissionReqWidget(
                    deviceSettingsCTA: () async => await openAppSettings(),
                  );
                } else {
                  return ErrorStateWidget(
                    onError: () => recorderBloc.add(LaunchRecorder()),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
