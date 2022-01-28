import 'dart:isolate';
import 'package:module_analyzer/src/starter/starter.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
