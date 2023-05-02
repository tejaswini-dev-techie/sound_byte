part of 'recordings_list_bloc.dart';

@immutable
abstract class RecordingsListState {}

class RecordingsListLoading extends RecordingsListState {}

class RecordingsListLoaded extends RecordingsListState {
  final List<FileSystemEntity>? files;

  RecordingsListLoaded(this.files);
}

class RecordingsListError extends RecordingsListState {}
