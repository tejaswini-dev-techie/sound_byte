import 'dart:io';

import 'package:audio_record_play_prj/Utils/recording_timer_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

part 'recorder_event.dart';
part 'recorder_state.dart';

class RecorderBloc extends Bloc<RecorderEvent, RecorderState> {
  RecorderBloc() : super(RecorderInitial()) {
    on<LaunchRecorder>((event, emit) async {
      emit(RecorderInitial());
    });
    on<InitRecord>((event, emit) async {
      await _mapRecordEvent(event, emit);
    });
    on<StopRecord>((event, emit) async {
      await _mapStopRecordEvent(event, emit);
    });
    on<PlayAudio>((event, emit) async {
      await _mapPlayAudioEvent(event, emit);
    });
    on<PauseAudio>((event, emit) async {
      await _mapPauseAudioEvent(event, emit);
    });
  }
  final Record audioRecorder = Record();
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<bool> get isRecording async => await audioRecorder.isRecording();
  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  TimeController? timeController = TimeController();

  Future<void> _mapRecordEvent(
      InitRecord event, Emitter<RecorderState> emit) async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.storage,
      Permission.microphone,
    ].request();

    Future<String> getFilePath() async {
      try {
        Directory storageDirectory = await getApplicationDocumentsDirectory();
        String sdPath = "";
        // "${storageDirectory.path}${Platform.pathSeparator}audio_recordings/";
        Directory appDocDirFolder =
            Directory('${storageDirectory.path}/audio_recordings/');

        if (await appDocDirFolder.exists()) {
          //if folder already exists return path
          sdPath = appDocDirFolder.path;
        } else {
          //if folder not exists create folder and then return its path
          appDocDirFolder = await appDocDirFolder.create(recursive: true);
          sdPath = appDocDirFolder.path;
        }
        return "${sdPath}aud_rec_${_timestamp()}.aac";
      } catch (e) {
        print("Get File Path ERROR: $e");
        return "";
      }
    }

    Future startRecorder() async {
      try {
        await audioRecorder.start(
          path: await getFilePath(),
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100,
        );
      } catch (e) {
        print("Start Recorder ERROR: $e");
      }
    }

    if (permissions[Permission.storage]!.isGranted &&
        permissions[Permission.microphone]!.isGranted) {
      if (!await audioRecorder.isRecording()) {
        await startRecorder();
        timeController?.startTimer();
      }
      emit(RecorderStart());
    } else if (permissions[Permission.storage]!.isPermanentlyDenied ||
        permissions[Permission.microphone]!.isPermanentlyDenied) {
      emit(PermissionRequest());
    } else {
      emit(RecorderInitial());
    }
  }

  Future<void> _mapStopRecordEvent(
      StopRecord event, Emitter<RecorderState> emit) async {
    try {
      if (await audioRecorder.isRecording()) {
        final String? audioPath = await audioRecorder.stop();
        print("Recorded audio: $audioPath");
        timeController?.stopTimer();
        emit(LocalAudioInit(audioPath ?? ""));
      } else {
        emit(RecorderError());
      }
    } catch (e) {
      print("Stop Recorder ERROR: $e");
      emit(RecorderError());
    }
  }

  Future<void> _mapPlayAudioEvent(
      PlayAudio event, Emitter<RecorderState> emit) async {
    try {
      if (event.audioPath.isNotEmpty) {
        await audioPlayer.pause();
        await audioPlayer.play(
          DeviceFileSource(
            event.audioPath,
          ),
        );

        audioPlayer.onPlayerComplete
            .listen((_) => add(PauseAudio(event.audioPath)));
        emit(PlayRecordedAudio(event.audioPath));
      } else {
        emit(RecorderError());
      }
    } catch (t) {
      print("Audio Player ERROR: $t");
      emit(RecorderError());
    }
  }

  Future<void> _mapPauseAudioEvent(
      PauseAudio event, Emitter<RecorderState> emit) async {
    try {
      await audioPlayer.pause();
      emit(LocalAudioInit(event.audioPath));
    } catch (t) {
      print("Audio Player ERROR: $t");
      emit(RecorderError());
    }
  }
}
