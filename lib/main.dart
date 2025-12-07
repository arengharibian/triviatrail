import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: initialize Firebase if you choose to use it
  // await Firebase.initializeApp();

  runApp(const TriviaTrailApp());
}
