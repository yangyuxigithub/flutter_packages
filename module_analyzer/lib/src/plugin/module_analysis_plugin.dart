import 'dart:async';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer/src/dart/analysis/context_root.dart' as analyzer;
import 'package:analyzer/src/dart/analysis/context_builder.dart' as analyzer;
import 'package:analyzer/src/workspace/basic.dart' as analyzer;
import 'package:analyzer/src/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:module_analyzer/src/issue/module_analysis_issue.dart';
import 'package:module_analyzer/src/logger/logger.dart';
import 'package:module_analyzer/src/visitor/module_analysis_visitor.dart';

class ModuleAnalysisPlugin extends ServerPlugin {

  ModuleAnalysisPlugin(ResourceProvider? provider) : super(provider);

  @override
  List<String> get fileGlobsToAnalyze => ['**/*.dart'];

  @override
  String get name => '模块化合规检查器';

  @override
  String get version => '1.0.0';

  var _filesFromSetPriorityFilesRequest = <String>[];

  //AS 中文件内容修改触发
  @override
  void contentChanged(String path) {
    // 每次在AS中修改文件都会触发
    AnalysisDriverGeneric? driver = super.driverForPath(path);
    driver?.addFile(path);
  }

  //AS 中切换tap标签页触发
  @override
  Future<AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
      AnalysisSetPriorityFilesParams parameters) async {
    _filesFromSetPriorityFilesRequest = parameters.files;
    _updatePriorityFiles();
    return AnalysisSetPriorityFilesResult();
  }

  //为contextRoot创建driver
  @override
  AnalysisDriverGeneric createAnalysisDriver(ContextRoot contextRoot) {
    //analysisLogger.info(contextRoot.exclude);
    //设置排除文件
    contextRoot.exclude.add('${contextRoot.root}/test');

    late AnalysisDriver driver;
    try {
      //设置扫描的根目录
      String rootPath = '${contextRoot.root}/lib';
      Folder rootFolder = resourceProvider.getFolder(rootPath);

      var workspace =
      analyzer.BasicWorkspace.find(resourceProvider, {}, rootPath);
      var analysisContextRoot =
      analyzer.ContextRootImpl(resourceProvider, rootFolder, workspace)
        ..optionsFile = resourceProvider.getFile(contextRoot.optionsFile!);

      var contextBuilder = analyzer.ContextBuilderImpl(
        resourceProvider: resourceProvider,
      );

      var analysisContext = contextBuilder.createContext(
        contextRoot: analysisContextRoot,
      );
      driver = analysisContext.driver;
    } catch (e) {
      logger.error(e);
    }

    runZonedGuarded(() {
      driver.results.listen((event) {
        logger.info(
            '${event.runtimeType} -- 路径: ${(event as FileResultImpl).path}');
        if (event.runtimeType == ResolvedUnitResultImpl) {
          ResolvedUnitResultImpl result = event as ResolvedUnitResultImpl;
          _processResult(driver, result);
        }
        if (event.runtimeType == ErrorsResultImpl) {
          ErrorsResultImpl result = event as ErrorsResultImpl;
        }
      });
    }, (Object e, StackTrace stackTrace) {
      //返回空结果
      logger.error('异常');
      channel.sendNotification(
          PluginErrorParams(false, e.toString(), stackTrace.toString())
              .toNotification());
    });

    return driver;
  }

  void _updatePriorityFiles() {
    Set addedFiles = {};
    for (final driver2 in driverMap.values) {
      for (var element in (driver2 as AnalysisDriver).addedFiles) {
        addedFiles.add(element);
      }
    }

    final filesToFullyResolve = {
      ..._filesFromSetPriorityFilesRequest,
      ...addedFiles
    };

    final filesByDriver = <AnalysisDriverGeneric, List<String>>{};
    for (final file in filesToFullyResolve) {
      //analysisLogger.error('解析结果：$file');
      final contextRoot = contextRootContaining(file as String);
      if (contextRoot != null) {
        final driver = driverMap[contextRoot];
        filesByDriver
            .putIfAbsent(driver as AnalysisDriverGeneric, () => <String>[])
            .add(file);
      }
    }
    filesByDriver.forEach((driver, files) => driver.priorityFiles = files);
  }

  void _processResult(
      AnalysisDriver driver, ResolvedUnitResult analysisResult) {
    try {
      final mirrorChecker = MirrorChecker(analysisResult.unit);
      final issues = mirrorChecker.enumToStringErrors();
      if (issues.isNotEmpty) {
        // 将结果发回给dartanalyzer服务，AS会自动显示在编辑器中
        channel.sendNotification(
          AnalysisErrorsParams(
            analysisResult.path,
            issues
                .map((issue) => analysisErrorFor(
                analysisResult.path, issue, analysisResult.unit))
                .toList(),
          ).toNotification(),
        );
      } else {
        channel.sendNotification(
            AnalysisErrorsParams(analysisResult.path, []).toNotification());
      }
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
          PluginErrorParams(false, e.toString(), stackTrace.toString())
              .toNotification());
    }
  }
}