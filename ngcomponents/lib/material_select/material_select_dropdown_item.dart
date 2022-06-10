// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:ngcomponents/dynamic_component/dynamic_component.dart';
import 'package:ngcomponents/material_checkbox/material_checkbox.dart';
import 'package:ngcomponents/material_icon/material_icon.dart';
import 'package:ngcomponents/material_select/activation_handler.dart';
import 'package:ngcomponents/material_select/handles_aria.dart';
import 'package:ngcomponents/material_select/material_select_item.dart';
import 'package:ngcomponents/mixins/material_dropdown_base.dart';
import 'package:ngcomponents/model/selection/selection_container.dart';
import 'package:ngcomponents/model/ui/has_renderer.dart';
import 'package:ngcomponents/utils/id_generator/id_generator.dart';

//import 'MaterialSelectItemComponent.template.dart' as templateItem;

/// Container for a single item selected in a dropdown.
///
/// This should only be used in select dropdowns.
@Component(
  selector: 'material-select-dropdown-item',
  providers: [
    ExistingProvider(SelectionItem, MaterialSelectDropdownItemComponent),
    ExistingProvider(HasRenderer, MaterialSelectDropdownItemComponent)
  ],
  styleUrls: ['material_select_dropdown_item.scss.css'],
  directives: [
    DynamicComponent,
    MaterialIconComponent,
    MaterialCheckboxComponent,
    NgIf
  ],
  templateUrl: 'material_select_item.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class MaterialSelectDropdownItemComponent<T>
    extends MaterialSelectItemComponent<T> implements OnDestroy {
  @HostBinding('class')
  static const hostClass = 'item';

  final String _generatedId;

  String? _id;

  /// The id of the element.
  @HostBinding('attr.id')
  String? get id => _customAriaHandling ? null : (_id ?? _generatedId);

  @Input()
  set id(String? id) {
    _id = id;
  }

  bool _customAriaHandling = false;

  MaterialSelectDropdownItemComponent(
      HtmlElement element,
      @Attribute('role') String? role,
      @Optional() DropdownHandle? dropdown,
      @Optional() ActivationHandler? activationHandler,
      @Optional() IdGenerator? idGenerator,
      ChangeDetectorRef cdRef,
      NgZone _zone)
      : _generatedId =
            (idGenerator ?? SequentialIdGenerator.fromUUID()).nextId(),
        super(element, dropdown, activationHandler, cdRef, role ?? 'option',
      _zone) {
    this.itemRenderer = defaultItemRenderer;
    //this.factoryRenderer =
    //    (_) => templateItem.MaterialSelectDropdownItemComponentNgFactory;
  }

  @HostBinding('attr.aria-selected')
  String get seletedStr => '$isSelected';

  @override
  bool get isSelected => super.isSelected;

  @HostListener('mousedown')
  void preventTextSelectionIfShiftKey(MouseEvent e) {
    if (e.shiftKey) e.preventDefault();
  }

  @override
  void onLoadCustomComponent(ComponentRef ref) {
    _customAriaHandling = ref.instance is HandlesAria;
    if (_customAriaHandling) role = null;
  }
}
