// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:ngcomponents/material_button/material_button.dart';
import 'package:ngcomponents/material_stepper/material_step.dart';
import 'package:ngcomponents/material_stepper/material_stepper.dart';
import 'package:ngcomponents/model/action/async_action.dart';
import 'package:angular_gallery_section/annotation/gallery_section_config.dart';
import 'package:ngcomponents/utils/angular/scroll_host/angular_2.dart';
import 'package:ngcomponents/button_decorator/button_decorator.dart';

@GallerySectionConfig(
  displayName: 'Material Stepper',
  docs: [MaterialStepperComponent, StepDirective],
  demos: [StepperDemoComponent],
  showGeneratedDocs: true,
)
class MaterialStepperGalleryConfig {}

@Component(
  selector: 'stepper-demo',
  providers: [scrollHostProviders],
  directives: [
    MaterialStepperComponent,
    StepDirective,
    SummaryDirective,
    ButtonDirective,
    MaterialButtonComponent,
    NgFor,
  ],
  templateUrl: 'material_stepper_demo.html',
  styleUrls: ['material_stepper_demo.scss.css'],
)
class StepperDemoComponent {
  bool? showButton = false;

  void toggleContinue() {
    showButton = !(showButton ?? false);
  }

  void validDelayedCheck(AsyncAction<bool> action) {
    action.cancelIf(Future.delayed(const Duration(seconds: 1), () {
      // Don't cancel
      return false;
    }));
  }
}
