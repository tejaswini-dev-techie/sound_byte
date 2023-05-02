part of 'recorder_bloc.dart';

@immutable
abstract class RecorderState {}

class RecorderInitial extends RecorderState {}

class RecorderStart extends RecorderState {}

class PermissionRequest extends RecorderState {}

class RecorderError extends RecorderState {}

class LocalAudioInit extends RecorderState {
  final String audioPath;

  LocalAudioInit(this.audioPath);
}

class PlayRecordedAudio extends RecorderState {
  final String audioPath;

  PlayRecordedAudio(this.audioPath);
}

class PauseRecordedAudio extends RecorderState {}
