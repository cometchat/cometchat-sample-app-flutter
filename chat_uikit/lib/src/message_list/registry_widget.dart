import 'package:flutter/widgets.dart';

class RegistryWidget extends StatefulWidget {
  const RegistryWidget({super.key, this.elementNotifier, required this.child});

  final Widget child;

  final ValueNotifier<Set<Element>?>? elementNotifier;

  @override
  State<StatefulWidget> createState() => _RegistryWidgetState();
}

class RegisteredElementWidget extends ProxyWidget {
  const RegisteredElementWidget({super.key, required super.child});

  @override
  Element createElement() => _RegisteredElement(this);
}

class _RegistryWidgetState extends State<RegistryWidget> {
  final Set<Element> registeredElements = {};

  @override
  Widget build(BuildContext context) =>
      _InheritedRegistryWidget(state: this, child: widget.child);
}

class _InheritedRegistryWidget extends InheritedWidget {
  final _RegistryWidgetState state;

  const _InheritedRegistryWidget({required this.state, required super.child});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}

class _RegisteredElement extends ProxyElement {
  _RegisteredElement(super.widget);

  @override
  void notifyClients(ProxyWidget oldWidget) {}

  late _RegistryWidgetState _registryWidgetState;

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    final inheritedRegistryWidget =
        dependOnInheritedWidgetOfExactType<_InheritedRegistryWidget>()!;
    _registryWidgetState = inheritedRegistryWidget.state;
    _registryWidgetState.registeredElements.add(this);
    _registryWidgetState.widget.elementNotifier?.value =
        _registryWidgetState.registeredElements;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inheritedRegistryWidget =
        dependOnInheritedWidgetOfExactType<_InheritedRegistryWidget>()!;
    _registryWidgetState = inheritedRegistryWidget.state;
    _registryWidgetState.registeredElements.add(this);
    _registryWidgetState.widget.elementNotifier?.value =
        _registryWidgetState.registeredElements;
  }

  @override
  void unmount() {
    _registryWidgetState.registeredElements.remove(this);
    _registryWidgetState.widget.elementNotifier?.value =
        _registryWidgetState.registeredElements;
    super.unmount();
  }
}
