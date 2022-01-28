import 'dart:isolate';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:module_analyzer/src/logger/logger.dart';
import 'package:module_analyzer/src/plugin/module_analysis_plugin.dart';

void start(List<String> args, SendPort sendPort) {
  logger.info('------------------------- 开始解析代码 -------------------------');
  ServerPluginStarter(ModuleAnalysisPlugin(PhysicalResourceProvider.INSTANCE)).start(sendPort);
}