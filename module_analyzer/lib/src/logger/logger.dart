import 'dart:convert';
import 'dart:io';
import 'package:module_analyzer/src/constant/constant.dart';
import 'package:quick_log/quick_log.dart';
import 'package:path/path.dart' as p;

class CustomLogger extends Logger {

  CustomLogger(String name) : super(name);

  static final Map<String, CustomLogger> _cache = {};

  factory CustomLogger.create(String name) {

    if (_cache.containsKey(name)) {
      return _cache[name]!;
    }

    var logger = CustomLogger(name);
    _cache[name] = logger;

    var home = '';
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME']!;
    }

    String path = '$home/$logFilePath';
    File logFile = File(p.absolute(path));
    if(!logFile.existsSync()) {
      logFile.createSync();
    }
    FileWriter fileWriter = FileWriter(file: logFile);
    fileWriter.init();

    var w = LogStreamWriter();
    Logger.writer = w;
    w.messages.listen((LogMessage message) {
      fileWriter.write('${message.timestamp} | ${message.level} | ${message.message}');
    });

    return logger;
  }
}

class FileWriter {
  late final File file;
  late final IOSink _sink;
  late Encoding encoding;

  FileWriter({required this.file, this.encoding = utf8});

  init() {
    _sink = file.openWrite(
      mode: FileMode.writeOnly,
      encoding: encoding
    );
  }

  //写入日志文件
  write(msg) {
    if (msg is Iterable) {
      _sink.writeAll(msg, '\n');
    } else if (msg is String) {
      _sink.writeln(msg);
    }
  }

  destroy() async {
    await _sink.flush();
    await _sink.close();
  }

}

var logger = CustomLogger.create('ILogger');