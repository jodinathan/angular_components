// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/laminate/overlay/constants.dart';
import 'package:angular_components/src/laminate/overlay/overlay_service.dart';
import 'package:angular_components/src/laminate/overlay/render/overlay_dom_render_service.dart';
import 'package:angular_components/src/laminate/overlay/render/overlay_style_config.dart';
import 'package:angular_components/laminate/overlay/zindexer.dart';
import 'package:angular_components/laminate/ruler/dom_ruler.dart';
import 'package:angular_components/model/math/box.dart';
import 'package:angular_components/utils/angular/imperative_view/imperative_view.dart';
import 'package:angular_components/utils/angular/managed_zone/angular_2.dart';
import 'package:angular_components/utils/browser/dom_service/angular_2.dart';
import 'package:angular_components/utils/browser/window/module.dart';

export 'package:angular_components/src/laminate/overlay/render/overlay_dom_render_service.dart'
    show
        overlayContainerName,
        overlayContainerParent,
        overlayContainerToken,
        overlayRepositionLoop,
        overlaySyncDom,
        overlayViewportBoundaries;

/// Creates an overlay container inside the [parent] if one does not exist
/// already.
/// A hidden focusable element is inserted before and after the overlay
/// container to support a11y features.
HtmlElement createAcxOverlayContainer(Object parent,
    {required String id, required String name, String? className}) {
  if (parent is! HtmlElement) {
    throw ArgumentError("Not a HtmlElement type");
  }
  var container = parent.querySelector('#$id');
  if (container == null) {
    container = DivElement()
      ..id = id
      ..classes.add(overlayContainerClassName);
    if (className != null) container.classes.add(className);
    parent.append(container);
  }
  container.attributes[overlayContainerNameAttribute] = name;
  return container as HtmlElement;
}

/// Either finds, or creates an "acx-overlay-container" div at the end of body.
@Injectable()
HtmlElement getDefaultContainer(
    @Inject(overlayContainerName) Object name,
    @Inject(overlayContainerParent) Object parent,
    @Optional() @SkipSelf() @Inject(overlayContainerToken) Object? container) {
  if (container != null) {
    return container as HtmlElement;
  }

  return createAcxOverlayContainer(parent,
      id: overlayDefaultContainerId, name: name as String);
}

@Injectable()
String getDefaultContainerName(
    @Optional()
    @SkipSelf()
    @Inject(overlayContainerName)
        Object? containerName) {
  return containerName as String? ?? 'default';
}

/// Returns an overlay container with debugging aid enabled.
@Injectable()
HtmlElement getDebugContainer(@Inject(overlayContainerName) Object name,
    @Inject(overlayContainerParent) Object parent) {
  var element = getDefaultContainer(name, parent, null);
  element.classes.add('debug');
  return element;
}

@Injectable()
HtmlElement getOverlayContainerParent(
    Document document,
    @Optional()
    @SkipSelf()
    @Inject(overlayContainerParent)
        Object? containerParent) {
  return containerParent as HtmlElement? ??
      document.querySelector('body') as HtmlElement;
}

/// DI module for Overlay and its dependencies.
const overlayModule = Module(
  include: [
    windowModule,
  ],
  provide: _overlayProviders,
);

const _overlayProviders = <Provider>[
  ClassProvider(AcxImperativeViewUtils),
  ClassProvider(DomRuler),
  domServiceBinding,
  ClassProvider(ManagedZone, useClass: Angular2ManagedZone),
  FactoryProvider.forToken(overlayContainerName, getDefaultContainerName),
  FactoryProvider.forToken(overlayContainerToken, getDefaultContainer),
  FactoryProvider.forToken(overlayContainerParent, getOverlayContainerParent),
  // Applications may experimentally make this true to increase performance.
  ValueProvider.forToken(overlaySyncDom, true),
  ValueProvider.forToken(overlayRepositionLoop, true),
  ValueProvider.forToken(overlayViewportBoundaries, Box()),
  ClassProvider(OverlayDomRenderService),
  ClassProvider(OverlayStyleConfig),
  ClassProvider(OverlayService),
  ClassProvider(ZIndexer),
];

/// DI bindings for Overlay and its dependencies.
const overlayBindings = [
  windowBindings,
  _overlayProviders,
];

/// Similar to [overlayModule], but enables easy debugging of the overlays.
const overlayDebugModule = Module(
  include: [
    overlayModule,
  ],
  provide: _overlayDebugProviders,
);

const _overlayDebugProviders = <Provider>[
  FactoryProvider.forToken(overlayContainerToken, getDebugContainer),
];

/// Similar to [overlayBindings], but enables easy debugging of the overlays.
const overlayDebugBindings = [
  overlayBindings,
  _overlayDebugProviders,
];
