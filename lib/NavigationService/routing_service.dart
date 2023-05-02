import 'package:audio_record_play_prj/NavigationService/routing_constants.dart';
import 'package:audio_record_play_prj/Screens/AudioPlayer/audio_player.dart';
import 'package:audio_record_play_prj/Screens/RecordScreen/record_audio_view.dart';
import 'package:audio_record_play_prj/Screens/RecordingsList/recordings_list_screen.dart';
import 'package:audio_record_play_prj/Screens/SplashScreen/splash_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(settings) {
    final args = settings.arguments;
    switch (settings.name) {
      /* Splash Screen */
      case RoutingConstants.routeDefault:
        return MaterialPageRoute(
          builder: (_) => const SplashScreenView(),
          settings: RouteSettings(name: settings.name),
        );

      case RoutingConstants.routeRecordAudio:
        return MaterialPageRoute(
          builder: (_) => const RecordAudioView(),
          settings: RouteSettings(name: settings.name),
        );

      case RoutingConstants.routeAudioListScreen:
        return MaterialPageRoute(
          builder: (_) => const RecordingsListScreen(),
          settings: RouteSettings(name: settings.name),
        );

      case RoutingConstants.routeAudioPlayerWidget:
        {
          if (args != "" && args != null) {
            Map<String, dynamic> data;
            data = args;
            return MaterialPageRoute(
              builder: (_) => AudioPlayerWidget(
                audioPath: data['data']['audio_path'] ?? "",
              ),
              settings: RouteSettings(
                name: settings.name,
              ),
            );
          } else {
            return MaterialPageRoute(
              builder: (_) => const AudioPlayerWidget(),
              settings: RouteSettings(
                name: settings.name,
              ),
            );
          }
        }

      /* Error Route */
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(pageName) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error_outline),
              Text(
                RoutingConstants.errPageText + pageName.toString(),
                style: TextStyle(
                  letterSpacing: 0.5,
                  height: 1.5,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
