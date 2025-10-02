import "package:rodzendai_form/core/utils/env_helper.dart";
import "package:universal_html/html.dart" as html;

class GoogleMapService {
  GoogleMapService._();
  String get apiKey => const String.fromEnvironment('GOOGLE_API_KEY');

  static Future<void> initialize() async {
    final apiKey = EnvHelper.googleAPIKey;

    if (apiKey.isEmpty) {
      throw Exception('Google Maps API Key not found');
    }

    final script =
        html.document.getElementById('google-maps-script')
            as html.ScriptElement?;

    if (script != null) {
      script.src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey';

      await script.onLoad.first;
    }
  }
}
