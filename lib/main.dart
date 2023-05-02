import 'package:audio_record_play_prj/NavigationService/routing_service.dart';
import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/SplashScreen/splash_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Audio Recorder',
          theme: ThemeData(
            fontFamily: 'Alegreya',
          ),
          initialRoute: RoutingConstants.routeDefault,
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          home: const SplashScreenView(),
        );
      },
    );
  }
}
