import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';

import 'services/payment/tabby_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Initialize Tabby SDK
  final tabbyApiKey = dotenv.env['TABBY_API_KEY'] ?? '';
  if (tabbyApiKey.isNotEmpty) {
    TabbyService().initialize(tabbyApiKey);
  }

  runApp(const ProviderScope(child: AqviooApp()));
}
