import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  print('Counting number of Dart files...');
  var count = 0;
  await Directory('lib').list(recursive: true).forEach((element) {
    if (element is File && p.extension(element.path) == '.dart') {
      count++;
    }
  });

  print('Analyzing...');

  final analyze = await Process.start('dart', ['analyze', '--format=machine']);

  var need_migrate = Set<String>();

  await analyze.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((element) {
    final output = element.split('|');

    if (output[0] == 'ERROR') {
      need_migrate.add(output[3]);
    }
  });

  print('${((1 - need_migrate.length / count) * 100).round()}% Done!');
  print(
      '${need_migrate.length} out of $count files still need to be migrated!');
}