import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'recordings_list_event.dart';
part 'recordings_list_state.dart';

class RecordingsListBloc
    extends Bloc<RecordingsListEvent, RecordingsListState> {
  RecordingsListBloc() : super(RecordingsListLoading()) {
    on<GetRecordingsFileList>((event, emit) async {
      await _mapGetRecordingsFileListEvent(event, emit);
    });
    on<DeleteFile>((event, emit) async {
      await _mapDeleteFileEvent(event, emit);
    });
  }

  List<FileSystemEntity>? files = [];
  Directory? appDocDir;
  Directory? appDocDirFolder;

  Future<void> _mapGetRecordingsFileListEvent(
      GetRecordingsFileList event, Emitter<RecordingsListState> emit) async {
    try {
      Future<void> getFiles() async {
        // Get this App Document Directory
        appDocDir = await getApplicationDocumentsDirectory();
        appDocDirFolder = Directory('${appDocDir?.path}/audio_recordings/');
        files = appDocDirFolder?.listSync(recursive: true);
      }

      await getFiles();
      emit(RecordingsListLoaded(files));
    } catch (e) {
      print("Fetching Files ERROR: $e");
      emit(RecordingsListError());
    }
  }

  Future<void> _mapDeleteFileEvent(
      DeleteFile event, Emitter<RecordingsListState> emit) async {
    try {
      Future<void> deleteFile() async {
        final path = appDocDirFolder?.path;
        print('PATH: $path${event.fileName}');
        await File('$path${event.fileName}.aac').delete();
      }

      await deleteFile();
      if (files != null && files!.isNotEmpty) {
        files?.removeAt(event.index!);
      }
      emit(RecordingsListLoaded(files));
    } catch (e) {
      print("Fetching Files ERROR: $e");
      emit(RecordingsListError());
    }
  }
}
