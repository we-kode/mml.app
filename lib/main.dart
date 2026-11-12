import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:mml_app/manager/image_cache_manager.dart';
import 'package:mml_app/mml_app.dart';
import 'package:mml_app/services/mml_http_overrides.dart';
import 'package:mml_app/services/share_link.dart';

/// Runs the application.
Future<void> main() async {
  HttpOverrides.global = MMLHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppLinks().uriLinkStream.listen(ShareLinkService.getInstance().open);
  await ImageCacheManager.init();
  runApp(const MMLApp());
}
