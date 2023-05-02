import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:audio_record_play_prj/Constants/string_constants.dart';
import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/RecordingsList/bloc/recordings_list_bloc.dart';
import 'package:audio_record_play_prj/Utils/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  State<RecordingsListScreen> createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends State<RecordingsListScreen> {
  /* Bloc Instance */
  final RecordingsListBloc recordingsListBloc = RecordingsListBloc();

  @override
  void initState() {
    super.initState();
    recordingsListBloc.add(GetRecordingsFileList());
  }

  @override
  void dispose() {
    recordingsListBloc.close();
    super.dispose();
  }

  void backAction() {
    Navigator.pushReplacementNamed(context, RoutingConstants.routeRecordAudio);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        backAction();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.4,
          title: Text(
            StringConstants.recordingsText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => backAction(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 14.sp,
            ),
          ),
        ),
        body: BlocBuilder<RecordingsListBloc, RecordingsListState>(
          bloc: recordingsListBloc,
          builder: (context, state) {
            if (state is RecordingsListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is RecordingsListLoaded) {
              return (state.files != null && state.files!.isNotEmpty)
                  ? ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 10.sp),
                      itemCount: state.files!.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: const ValueKey(
                            "delete",
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {}
                          },
                          confirmDismiss: (direction) async {
                            recordingsListBloc.add(DeleteFile(
                                state.files![index]
                                    .toString()
                                    .split("/")
                                    .last
                                    .split(".aac")[0],
                                index));
                            return false;
                          },
                          background: Container(
                            color: ColorConstants.redColor,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.sp),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    Text(
                                      StringConstants.deleteText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Map<String, dynamic> routeData = {};
                              routeData = {
                                "audio_path": state.files![index].path,
                              };
                              Navigator.of(context).pushReplacementNamed(
                                RoutingConstants.routeAudioPlayerWidget,
                                arguments: {
                                  "data": routeData,
                                },
                              );
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: Icon(
                              Icons.music_note_sharp,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                            title: Text(
                              state.files![index]
                                  .toString()
                                  .split("/")
                                  .last
                                  .split(".aac")[0],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.black,
                        );
                      },
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 10.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            StringConstants.noRecordingsText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 8.sp,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, RoutingConstants.routeRecordAudio);
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
                      ),
                    );
            } else {
              return ErrorStateWidget(
                onError: () => recordingsListBloc.add(GetRecordingsFileList()),
              );
            }
          },
        ),
      ),
    );
  }
}
