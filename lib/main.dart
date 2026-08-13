import 'package:flutter/material.dart';
import 'package:my_gwent/database/app_database.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.resetDatabase();

  runApp(const MyApp());
}
