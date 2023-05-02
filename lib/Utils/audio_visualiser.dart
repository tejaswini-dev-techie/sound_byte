import 'package:audio_record_play_prj/Constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AudioVisualiser extends StatelessWidget {
  AudioVisualiser({
    Key? key,
  }) : super(key: key);

  final List<int> duration = [
    1200,
    800,
    1000,
    600,
    450,
    760,
    980,
    1300,
    456,
    789,
    1000,
    345,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        20,
        (index) => VisualComponent(
          duration: duration[index % 7],
        ),
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  final int? duration;

  const VisualComponent({
    Key? key,
    required this.duration,
  }) : super(key: key);

  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.duration ?? 500,
      ),
    );
    final curvedAnimation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOutSine,
    );
    animation = Tween<double>(begin: 0, end: 100).animate(curvedAnimation
      ..addListener(() {
        setState(() {});
      }));

    animationController?.repeat(reverse: true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: 1.w,
      height: animation!.value / 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ColorConstants.darkBlueGradient,
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(6.sp)),
      ),
    );
  }
}
