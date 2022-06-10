// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html' show KeyCode, KeyboardEvent, Element, HtmlElement,
document, window;

import 'package:angular/angular.dart';
import 'package:meta/meta.dart';
import 'package:ngcomponents/laminate/components/modal/modal.dart';
import 'package:ngcomponents/laminate/popup/popup.dart';
import 'package:ngcomponents/utils/browser/dom_service/dom_service.dart';
import 'package:ngcomponents/utils/disposer/disposer.dart';

import '../content/deferred_content_aware.dart';
import 'focus_interface.dart';

export 'focus_interface.dart';

/// A class for components to extend if their programmatic focus
/// should simply put focus on root element.
class RootFocusable implements Focusable {
  RootFocusable(this._root, this._zone);

  final Element? _root;
  final NgZone _zone;

  @override
  void focus() {
    final _root = this._root;

    if (_root == null) return;
    // if element does not have positive tab index attribute already specified
    // or is native element.
    // NOTE: even for elements with tab index unspecified it will return
    // tabIndex as "-1" and we have to set it to "-1"
    // to actually make it focusable.
    if (_root.tabIndex! < 0) {
      _root.tabIndex = -1;
    }

    if (document.activeElement != null &&
        document.activeElement != document.body) {
      do {
        document.activeElement!.blur();
      } while (document.activeElement != null &&
          document.activeElement != document.body);

      _zone.runAfterChangesObserved(_root.focus);
    } else {
      _root.focus();
    }
  }
}

/// A focusable component that can publish to the
/// `focusmove` stream in order to move focus to another element in the list.
abstract class FocusableItem implements Focusable {
  /// Moves focus item into (tabIndex='0') or out of (tabIndex='-1') tab order.
  set tabbable(bool value);

  /// The item publishes to this stream in order to move focus to another item.
  Stream<FocusMoveEvent> get focusmove;
}

/// An event to trigger moving focus to another item in a list.
class FocusMoveEvent {
  /// The component which published this event.
  final FocusableItem focusItem;

  /// The position, relative the item, of where to set focus.
  final int offset;

  /// Home key was pressed.
  final bool home;

  /// End key was pressed.
  final bool end;

  /// Up or down arrow key was pressed.
  final bool upDown;

  final bool _none;

  bool get valid => !_none;

  /// Prevent Default action for occuring. When the `FocusMoveEvent` is created
  /// from a KeyboardEvent, this method delegates to the `preventDefault` method
  /// of the `KeyboardEvent`, allowing consumers of this event to control the
  /// underlying DOM event.
  void preventDefault() {
    if (_preventDefaultDelegate != null) _preventDefaultDelegate!();
  }

  final Function? _preventDefaultDelegate;

  @visibleForTesting
  FocusMoveEvent(this.focusItem, this.offset, [this._preventDefaultDelegate])
      : home = false,
        end = false,
        upDown = false,
        _none = false;

  @visibleForTesting
  FocusMoveEvent.homeKey(this.focusItem, [this._preventDefaultDelegate])
      : offset = 0,
        home = true,
        end = false,
        upDown = false,
        _none = false;

  @visibleForTesting
  FocusMoveEvent.endKey(this.focusItem, [this._preventDefaultDelegate])
      : offset = 0,
        home = false,
        end = true,
        upDown = false,
        _none = false;

  @visibleForTesting
  FocusMoveEvent.upDownKey(this.focusItem, this.offset,
      [this._preventDefaultDelegate])
      : home = false,
        end = false,
        upDown = true,
        _none = false;

  @visibleForTesting
  FocusMoveEvent.none(this.focusItem, this.offset,
      [this._preventDefaultDelegate])
      : home = false,
        end = false,
        upDown = false,
        _none = true;

  /// Builds a `FocusMoveEvent` instance from a keyboard event, iff the keycode
  /// is a next, previous, home or end key (i.e. up/down/left/right/home/end).
  factory FocusMoveEvent.fromKeyboardEvent(
      FocusableItem item, KeyboardEvent kbEvent) {
    int keyCode = kbEvent.keyCode;
    final preventDefaultFn = () {
      kbEvent.preventDefault();
    };
    if (_isHomeKey(keyCode)) {
      return FocusMoveEvent.homeKey(item, preventDefaultFn);
    }
    if (_isEndKey(keyCode)) {
      return FocusMoveEvent.endKey(item, preventDefaultFn);
    }
    if (!_isNextKey(keyCode) && !_isPrevKey(keyCode)) {
      //return null;
      return FocusMoveEvent.none(item, 0);
    }

    int offset = _isNextKey(keyCode) ? 1 : -1;
    if (keyCode == KeyCode.UP || keyCode == KeyCode.DOWN) {
      return FocusMoveEvent.upDownKey(item, offset, preventDefaultFn);
    }

    return FocusMoveEvent(item, offset, preventDefaultFn);
  }

  // TODO(google): account for RTL.
  static bool _isNextKey(int keyCode) =>
      keyCode == KeyCode.RIGHT || keyCode == KeyCode.DOWN;
  static bool _isPrevKey(int keyCode) =>
      keyCode == KeyCode.LEFT || keyCode == KeyCode.UP;
  static bool _isHomeKey(int keyCode) => keyCode == KeyCode.HOME;
  static bool _isEndKey(int keyCode) => keyCode == KeyCode.END;
}

/// The element will be focused as soon as directive is initialized.
///
/// Please put only on content that appears after user action and
/// requires focus to be changed to it.
@Directive(
  selector: '[autoFocus]',
)
class AutoFocusDirective extends RootFocusable implements OnInit, OnDestroy {
  final _disposer = Disposer.oneShot();

  late bool _autoFocus;
  // These fields are not final to support nulling them out for easier memory
  // leak detection.
  Focusable? _focusable;
  DomService _domService;
  DeferredContentAware? _contentAware;

  AutoFocusDirective(
      HtmlElement node,
      this._domService,
      @Self() @Optional() this._focusable,
      @Optional() this._contentAware,
      NgZone _zone)
      : super(node, _zone);

  @override
  void ngOnInit() {
    window.console.log('FOCUS?INIT $_autoFocus, $_focusable, ${this._contentAware}');
    if (!_autoFocus) return;

    //_defocus();

    final _contentAware = this._contentAware;

    if (_contentAware != null) {
      _onModalOrPopupVisibleChanged(_contentAware.isVisible);

      _disposer.addStreamSubscription(
          _contentAware.contentVisible.listen(_onModalOrPopupVisibleChanged));
    } else {
      _domService.scheduleWrite(focus);
    }
  }

  /// Enables the auto focus directive so that it can be conditionally applied.
  ///
  /// This value should not change during the component's life.
  // TODO(google): Change to an attribute.
  @Input()
  set autoFocus(bool? value) {
    _autoFocus = value ?? false;
  }

  @override
  void focus() {
    print('FOCUS? $_autoFocus, $_focusable, $this');
    if (!_autoFocus) return;

    if (_focusable != null) {
      _focusable!.focus();
    } else {
      super.focus();
    }
  }

  @override
  void ngOnDestroy() {
    _disposer.dispose();
    _focusable = null;
    //_domService = null;
    _contentAware = null;
  }

  void _onModalOrPopupVisibleChanged(bool isVisible) {
    print('FOcusIsVis ${isVisible}');
    if (isVisible) _domService.scheduleWrite(focus);
  }
}

/// Tags an element as being [Focusable].
///
/// Tagging elements as [Focusable] allows other components to easily access
/// which elements can be focused and perform actions on them.
@Directive(
    selector: '[focusableElement]',
    exportAs: 'focusableElement',
    providers: [ExistingProvider(Focusable, FocusableDirective)])
class FocusableDirective extends RootFocusable {
  FocusableDirective(HtmlElement node, NgZone zone) : super(node, zone);
}
