import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // ProviderScope must wrap the whole app - it's what stores
  // all provider state (taskProvider included).
  runApp(const ProviderScope(child: MyApp()));
}