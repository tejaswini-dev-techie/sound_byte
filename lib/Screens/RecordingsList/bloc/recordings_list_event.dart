part of 'recordings_list_bloc.dart';

@immutable
abstract class RecordingsListEvent {}

class GetRecordingsFileList extends RecordingsListEvent {}

class DeleteFile extends RecordingsListEvent {
  final String? fileName;
  final int? index;

  DeleteFile(this.fileName, this.index);
}
