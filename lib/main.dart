import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dramnyen_tuner/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DranyenApp());
}
