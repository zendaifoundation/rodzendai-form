import 'dart:developer';

import 'package:rodzendai_form/core/utils/env_helper.dart';

class Apis {
  const Apis._();

  static String get baseUrl {
    final url = EnvHelper.baseUrl;
    log('🔗 [Apis] Base URL for : $url');
    return url;
  }
}
