// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//import 'dart:html';

import 'package:angular/angular.dart';
import 'package:ngcomponents/model/ui/display_name.dart';
import 'package:ngcomponents/model/ui/has_renderer.dart';

/// Add this directive to any [SelectionContainer] or [SelectionItem]
/// component to render [HasUIDisplayName] objects.
@Directive(
  selector: '[displayNameRenderer]',
  //visibility: Visibility.all,
)
class DisplayNameRendererDirective<T> {
  final HasRenderer hasRenderer;

  DisplayNameRendererDirective(this.hasRenderer) {
    hasRenderer.itemRenderer = _displayNameRenderer;
  }

  /*
  ItemRenderer<T>? _itemRenderer;

  @override
  ItemRenderer<T>? get itemRenderer => _itemRenderer ?? _displayNameRenderer;

  /// A rendering function to render selection options to a String, if given a
  /// `value`.
  @Input()
  set itemRenderer(ItemRenderer<T>? renderer) {
    _itemRenderer = renderer;
  }
  */
}

final _displayNameRenderer =
    (dynamic item) => (item as HasUIDisplayName).uiDisplayName;
