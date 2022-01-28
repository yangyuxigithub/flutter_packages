import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:module_analyzer/src/constant/constant.dart';
import 'package:module_analyzer/src/issue/module_analysis_issue.dart';

class MirrorChecker {
  final CompilationUnit _compilationUnit;
  String? unitPath;

  MirrorChecker(this._compilationUnit) {
    unitPath = _compilationUnit.declaredElement!.source.fullName;
  }

  Iterable<ModuleAnalysisIssue> enumToStringErrors() {
    final visitor = _MirrorVisitor();
    visitor.unitPath = unitPath!;
    _compilationUnit.accept(visitor);
    return visitor.issues;
  }
}

class _MirrorVisitor extends RecursiveAstVisitor<void> {
  String? unitPath;
  final _issues = <ModuleAnalysisIssue>[];

  Iterable<ModuleAnalysisIssue> get issues => _issues;

  @override
  void visitImportDirective(ImportDirective node) {

    if (node.selectedSource != null && unitPath!.contains(modulePath)) {
      //每一个import的绝对路径
      String path = node.selectedSource!.fullName;
      Uri uri = node.selectedSource!.uri;

      if (path.contains(modulePath)) {
        List list = unitPath!.split('/');
        int index = list.indexOf(moduleDir) + 1;
        String p1 = list[index];

        list = uri.pathSegments;
        index = list.indexOf(moduleDir) + 1;
        String p2 = list[index];

        if (p1 != p2) {
          _issues.add(
            ModuleAnalysisIssue(
              AnalysisErrorSeverity.ERROR,
              AnalysisErrorType.LINT,
              node.offset,
              node.length,
              errorTip,
              'fucking code',
            ),
          );
        }
      }
    }
    node.visitChildren(this);
  }
}
