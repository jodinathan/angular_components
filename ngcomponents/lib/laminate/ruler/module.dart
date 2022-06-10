// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:ngcomponents/laminate/ruler/dom_ruler.dart';
import 'package:ngcomponents/laminate/ruler/ng_ruler.dart';
import 'package:ngcomponents/utils/angular/managed_zone/angular_2.dart';
import 'package:ngcomponents/utils/browser/dom_service/angular_2.dart';
import 'package:ngcomponents/utils/browser/window/module.dart';

/// Providers for using the ruler service.
const rulerBindings = [_rulerProviders, domServiceBinding, windowBindings];

/// DI module for ruler service.
const rulerModule = Module(include: [
  domServiceModule,
  windowModule,
], provide: _rulerProviders);

const _rulerProviders = [
  ClassProvider(DomRuler),
  ClassProvider(ManagedZone, useClass: Angular2ManagedZone),
  ClassProvider(NgRuler),
];
