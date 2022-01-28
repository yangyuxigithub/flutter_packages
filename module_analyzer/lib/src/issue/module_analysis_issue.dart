import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

class ModuleAnalysisIssue {
  final AnalysisErrorSeverity analysisErrorSeverity;
  final AnalysisErrorType analysisErrorType;
  final int offset;
  final int length;
  final String message;
  final String code;

  ModuleAnalysisIssue(
    this.analysisErrorSeverity,
    this.analysisErrorType,
    this.offset,
    this.length,
    this.message,
    this.code,
  );
}

//映射ModuleAnalysisIssue到AnalysisError
AnalysisError analysisErrorFor(
    String path, ModuleAnalysisIssue issue, CompilationUnit unit) {
  final offsetLocation = unit.lineInfo!.getLocation(issue.offset);
  return AnalysisError(
    issue.analysisErrorSeverity,
    issue.analysisErrorType,
    Location(
      path,
      issue.offset,
      issue.length,
      offsetLocation.lineNumber,
      offsetLocation.columnNumber,
    ),
    issue.message,
    issue.code,
  );
}
