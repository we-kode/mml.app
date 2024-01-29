import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Expandable FAB action button.
///
/// A floationg action button whcih has muliple sub action buttons,
/// which will be expandeed when clicked on the button.
@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  /// True, if initial the button is opened.
  final bool? initialOpen;

  /// distance between the sub buttons.
  final double distance;

  /// Sub action buttons.
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

/// State of the [ExpandableFab].
class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  /// Animation controller of the FAB.
  late final AnimationController _controller;

  /// The expand animation when the button is expanding or collapsing.
  late final Animation<double> _expandAnimation;

  /// State of the [ExpandableFab].
  ///
  /// true if [ExpandableFab] is expanded, false otherwise.
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Toggles open state of FAB.
  void _toggle() {
    setState(
      () {
        _open = !_open;
        if (_open) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  /// The button shown, when the FAB is in expand state.
  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the sub fabs.
  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  /// Button shown when FAB is in collapse state.
  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

/// Trasnisiton widget of the [ExpandableFab], which is performed when the button changes from collapsed to expand
/// state and in the other direction.
@immutable
class _ExpandingActionButton extends StatelessWidget {
  /// Initializes the [_ExpandingActionButton].
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  /// Degrees of expanding buttons.
  final double directionInDegrees;

  /// The max distance between expanded sub fabs.
  final double maxDistance;

  /// The progress of expanding or collapsing.
  final Animation<double> progress;

  /// Child widget shown when expanding.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

/// One sub action button.
@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  /// Called when button is pressed.
  final VoidCallback? onPressed;

  /// Icon of this action button.
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.primary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
