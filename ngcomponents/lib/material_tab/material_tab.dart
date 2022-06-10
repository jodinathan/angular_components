// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:ngcomponents/content/deferred_content_aware.dart';
import 'package:ngcomponents/focus/focus.dart';
import 'package:ngcomponents/laminate/portal/portal.dart';
import 'package:ngcomponents/utils/id_generator/id_generator.dart';

/// Basic interface for a Tab.
abstract class Tab extends Focusable {
  /// The label to be shown on the tab button.
  TemplatePortal? get label;

  /// The unique id for the tab button.
  String get tabId;

  /// Sets this tab as active.
  void activate();

  /// Sets this tab as inactive.
  void deactivate();
}

/// A Material-styled card, which is shown or hidden as part of a
/// [MaterialTabPanelComponent].
///
/// The `material-tab` component sets the button's label text via the `label`
/// property. Tab contents can be lazily instantiated by using the
/// `*deferredContent` template directive.
@Component(
  selector: 'material-tab',
  providers: [
    ExistingProvider(Tab, MaterialTabComponent),
    ExistingProvider(DeferredContentAware, MaterialTabComponent),
  ],
  template: '''
        <div class="tab-content" *ngIf="active" #content>
          <ng-content></ng-content>
        </div>
        <template portal #label="portal">
          <ng-content select="[tab-label]"></ng-content>
        </template>
  ''',
  styleUrls: ['material_tab.scss.css'],
  directives: [NgIf, TemplatePortalDirective],
  changeDetection: ChangeDetectionStrategy.OnPush
)
class MaterialTabComponent extends RootFocusable
    implements Tab, DeferredContentAware {
  @HostBinding('attr.role')
  static const hostRole = 'tabpanel';

  final String _uuid;
  final _visible = StreamController<bool>.broadcast(sync: true);
  final ChangeDetectorRef _cd;

  MaterialTabComponent(
      HtmlElement element, @Optional() IdGenerator? idGenerator, this._cd,
      NgZone _zone)
      : _uuid = (idGenerator ?? SequentialIdGenerator.fromUUID()).nextId(),
        super(element, _zone);

  @ViewChild('content')
  set content(DivElement? div) {
    _visibility(div != null);
  }

  bool _isVisible = false;
  bool get isVisible => _isVisible;

  /// The label for this tab.
  @override
  @ViewChild('label')
  TemplatePortalDirective? label;

  void _visibility(bool visible) {
    _isVisible = visible;
    _visible.add(visible);
  }

  @override
  void deactivate() {
    _active = false;
    _visibility(false);
    _cd.markForCheck();
  }

  @override
  void activate() {
    _active = true;
    _visibility(true);
    _cd.markForCheck();
  }

  @override
  Stream<bool> get contentVisible => _visible.stream;

  /// Whether the tab is active.
  @HostBinding('class.material-tab')
  bool get active => _active;
  bool _active = false;

  /// HTML ID for the panel.
  @HostBinding('attr.id')
  String get panelId => 'panel-$_uuid';

  /// HTML ID for the tab.
  @HostBinding('attr.aria-labelledby')
  @override
  String get tabId => 'tab-$_uuid';
}
