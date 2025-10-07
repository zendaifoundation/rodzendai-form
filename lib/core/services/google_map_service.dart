import "package:rodzendai_form/core/utils/env_helper.dart";
import "package:web/web.dart" as web;

class GoogleMapService {
  GoogleMapService._();
  String get apiKey => const String.fromEnvironment('GOOGLE_API_KEY');

  static Future<void> initialize() async {
    final apiKey = EnvHelper.googleAPIKey;

    if (apiKey.isEmpty) {
      throw Exception('Google Maps API Key not found');
    }

    final script =
        web.document.getElementById('google-maps-script')
            as web.HTMLScriptElement?;

    if (script != null) {
      script.src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&loading=async&libraries=drawing,visualization,places,marker&callback=initApp';

      await script.onLoad.first;
    }
  }
}
