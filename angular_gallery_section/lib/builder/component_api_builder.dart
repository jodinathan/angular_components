// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:mustache_template/mustache.dart' show Template;
import 'package:path/path.dart' as p;
import 'package:angular_gallery_section/resolved_config.dart';
import 'package:angular_gallery_section/components/gallery_component/documentation_info.dart';

/// A builder for generating an API page for an Angular component.
///
/// The "API page" is in the form of Dart code, with an Angular component
/// whose template includes information about a component annotated with
/// @GallerySectionConfig.
class ComponentApiBuilder extends Builder {
  static const libPath = 'lib/';

  @override
  Future build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final infoList = (jsonDecode(await buildStep.readAsString(inputId)) as List)
        .map((info) => ResolvedConfig.loadJson(info));

    final mustacheContext = await _mustacheContext(infoList);
    final templateId = AssetId('angular_gallery_section',
        'lib/builder/template/component.api.dart.mustache');
    final mustacheTemplate = Template(await buildStep.readAsString(templateId),
        htmlEscapeValues: false);

    final newAssetId = AssetId(inputId.package,
        inputId.path.replaceFirst('.gallery_info.json', '.api.dart'));

    var renderedData = mustacheTemplate.renderString(mustacheContext);
    //print("=== Start(examples.api.dart) ===");
    //print(renderedData);
    //print("=== End ===");

    await buildStep.writeAsString(newAssetId, renderedData);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.gallery_info.json': ['.api.dart']
      };

  /// Returns a context with the useful values from the [configs].
  Future<Map<String, dynamic>> _mustacheContext(
      Iterable<ResolvedConfig> configs) async {
    final dedupedImports = <String>{};
    final context = <String, dynamic>{'apiComponents': []};
    for (final config in configs) {
      // If multiple components are defined in a demo file, we would end up with
      // duplicate imports, so de dup them.

      dedupedImports.addAll(config.demos.cast().map((d) => d!.import));

      if (config.mainDemo != null) {
        dedupedImports.add(config.mainDemo!.import);
      }

      context['apiComponents'].add({
        'component': config.classSafeName,
        'selector': config.selectorSafeName,
        'demos': config.demos.map((demo) => {
              'className': demo.name,
              'dartImport': demo.import,
              'examplePath': demo.path,
            }),
        'hasMainDemo': config.mainDemo != null,
        'mainDemo': {
          'className': config.mainDemo?.name,
          'dartImport': config.mainDemo?.import,
          'examplePath': config.mainDemo?.path,
        },
        'docs': config.docs.map((doc) {
          var jsonMap = doc.toJson();
          // Add flags to identify the DocInfo constuctor to use later.
          jsonMap['dartDoc'] = doc.docType == DocType.dartDocInfo;
          jsonMap['markdownDoc'] = doc.docType == DocType.markdownDocInfo;
          jsonMap['sassDoc'] = doc.docType == DocType.sassDocInfo;
          return jsonMap;
        }).toList(),
        'owners': config.owners,
        'uxOwners': config.uxOwners,
        'relatedUrls': config.relatedUrls.entries
            .map((entry) => {'key': entry.key, 'value': entry.value}),
        'showGeneratedDocs': config.showGeneratedDocs,
      });
    }
    context['demoImports'] = dedupedImports.map<Map<String, String>>(
        (dartImport) =>
            {'dartImport': p.url.setExtension(dartImport, '.template.dart')});
    return context;
  }
}
