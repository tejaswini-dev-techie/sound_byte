part of 'recorder_bloc.dart';

@immutable
abstract class RecorderEvent {}

class LaunchRecorder extends RecorderEvent {}

class InitRecord extends RecorderEvent {}

class StopRecord extends RecorderEvent {}

class PlayAudio extends RecorderEvent {
  final String audioPath;

  PlayAudio(this.audioPath);
}

class PauseAudio extends RecorderEvent {
  final String audioPath;

  PauseAudio(this.audioPath);
}
