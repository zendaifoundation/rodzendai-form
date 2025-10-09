import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Helper class สำหรับจัดการ navigation อย่างปลอดภัย
class NavigationHelper {
  /// Navigate อย่างปลอดภัย โดยเช็ค mounted state ก่อน
  static void safeGo(BuildContext context, String location, {Object? extra}) {
    try {
      if (context.mounted) {
        context.go(location, extra: extra);
        log('🧭 Navigation to: $location');
      } else {
        log('⚠️ Cannot navigate: context not mounted');
      }
    } catch (e) {
      log('❌ Navigation error: $e');
    }
  }

  /// Push อย่างปลอดภัย
  static void safePush(BuildContext context, String location, {Object? extra}) {
    try {
      if (context.mounted) {
        context.push(location, extra: extra);
        log('🧭 Push to: $location');
      } else {
        log('⚠️ Cannot push: context not mounted');
      }
    } catch (e) {
      log('❌ Push error: $e');
    }
  }

  /// Replace อย่างปลอดภัย
  static void safeReplace(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    try {
      if (context.mounted) {
        context.replace(location, extra: extra);
        log('🧭 Replace to: $location');
      } else {
        log('⚠️ Cannot replace: context not mounted');
      }
    } catch (e) {
      log('❌ Replace error: $e');
    }
  }
}
