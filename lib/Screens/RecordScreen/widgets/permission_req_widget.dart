import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:audio_record_play_prj/Constants/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PermissionReqWidget extends StatelessWidget {
  final Function deviceSettingsCTA;
  const PermissionReqWidget({super.key, required this.deviceSettingsCTA});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            StringConstants.reqPermission,
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
            onTap: () => deviceSettingsCTA(),
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
                StringConstants.deviceSettingsText,
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
  }
}
