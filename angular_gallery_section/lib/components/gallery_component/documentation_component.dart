// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:ngsecurity/security.dart';
import 'package:angular_gallery_section/components/gallery_component/gallery_info.dart';
import 'package:sanitize_html/sanitize_html.dart' show sanitizeHtml;

/// A list of all documentation directives.
const documentationComponentDirectives = [
  DartDocComponent,
  MarkdownDocComponent,
  SassDocComponent,
];

class DocumentationComponent {
  @Input()
  bool showGeneratedDocs = false;

  String getSafeHtml(String value) {
    return sanitizeHtml(value);
  }
}

/// Displays documentation for dart files in the gallery application.
///
/// Docs are expected to be generated for Angular @Components and @Directives.
@Component(
  selector: 'documentation-component[dart]',
  directives: [
    NgFor,
    NgIf,
    SafeInnerHtmlDirective,
  ],
  templateUrl: 'dart_doc_component.html',
  styleUrls: ['documentation_component.scss.css'],
)
class DartDocComponent extends DocumentationComponent {
  /// The documentation to display.
  @Input()
  set doc(DocInfo d) {
    if (d is DartDocInfo) {
      _doc = d;
    }
  }

  DartDocInfo get doc => _doc;

  DartDocInfo _doc = DartDocInfo.loadJson({});
}

/// Displays a single piece of documentation.
///
/// Typically used for the generated HTML from a markdown README.
@Component(
    selector: 'documentation-component[markdown]',
    template: '<div [innerHtml]="doc.contents"></div>',
    styleUrls: ['documentation_component.scss.css'])
class MarkdownDocComponent extends DocumentationComponent {
  /// The documentation to display.
  @Input()
  set doc(DocInfo d) {
    if (d is MarkdownDocInfo) {
      _doc = d;
    }
  }

  MarkdownDocInfo get doc => _doc;

  MarkdownDocInfo _doc = MarkdownDocInfo.loadJson({});
}

/// Displays documentation for Sass files in the gallery application.
///
/// Includes documentation for all variables, functions and mixins avaliable
/// by importing the Sass file.
@Component(
  selector: 'documentation-component[sass]',
  directives: [
    NgFor,
    NgIf,
    SafeInnerHtmlDirective,
  ],
  templateUrl: 'sass_doc_component.html',
  styleUrls: ['documentation_component.scss.css'],
)
class SassDocComponent extends DocumentationComponent {
  /// The documentation to display.
  @Input()
  set doc(DocInfo d) {
    if (d is SassDocInfo) {
      _doc = d;
    }
  }

  SassDocInfo get doc => _doc;

  SassDocInfo _doc = SassDocInfo.loadJson({});
}
