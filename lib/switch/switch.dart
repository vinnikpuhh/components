import 'package:flutter/material.dart';

class SwitchAppearance {
  final Size trackSize;
  final Widget Function(BuildContext ctx, double anim)? trackBuilder;
  final Widget Function(BuildContext ctx, double anim)? thumbBuilder;

  SwitchAppearance({
    this.trackSize = _appSwitchDefaultTrackSize,
    this.thumbBuilder,
    this.trackBuilder,
  });
}

/// A custom switch implementation, because Flutter's own is unfitting.
///
/// Thumb size is [trackSize.height].
class AppSwitch extends StatefulWidget {
  final bool isActive;
  final void Function(bool active) onToggled;
  final SwitchAppearance? appearance;

  AppSwitch({
    Key? key,
    required this.isActive,
    required this.onToggled,
    this.appearance,
  })  : assert(() {
          if (appearance == null) return true;
          return appearance.trackSize.width > appearance.trackSize.height;
        }()),
        super(key: key);

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 250,
    ),
  );

  Size get size => widget.appearance?.trackSize ?? _appSwitchDefaultTrackSize;

  @override
  void didUpdateWidget(covariant AppSwitch oldWidget) {
    if (widget.isActive &&
        (controller.status == AnimationStatus.dismissed ||
            controller.status == AnimationStatus.reverse)) {
      controller.forward();
    } else if (!widget.isActive &&
        (controller.status == AnimationStatus.completed ||
            controller.status == AnimationStatus.forward)) {
      controller.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.isAnimating) {
          controller.stop();
        }

        if (!widget.isActive) {
          controller.forward();
          widget.onToggled(true);
        } else {
          controller.reverse();
          widget.onToggled(false);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: SizedBox.fromSize(
        size: size,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, anim) {
            return Stack(
              children: [
                Positioned.fill(child: track(context)),
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  width: size.height,
                  left: getThumbLeftOffset(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (det) {
                      controller.stop();
                    },
                    onHorizontalDragUpdate: (det) {
                      final dx = det.primaryDelta!;
                      final dPercent = dx / (size.width - size.height);
                      controller.value = controller.value + dPercent;
                    },
                    onHorizontalDragEnd: (det) {
                      if (controller.value > .5) {
                        controller.animateTo(1.0);
                        widget.onToggled(true);
                      } else {
                        controller.animateTo(0.0);
                        widget.onToggled(false);
                      }
                    },
                    child: thumb(context),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget track(BuildContext context) {
    if (widget.appearance?.trackBuilder != null) {
      return widget.appearance!.trackBuilder!(context, controller.value);
    } else {
      return _defaultTrack();
    }
  }

  Widget thumb(BuildContext context) {
    if (widget.appearance?.thumbBuilder != null) {
      return widget.appearance!.thumbBuilder!(context, controller.value);
    } else {
      return _defaultThumb();
    }
  }

  Widget _defaultTrack() {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(size.height / 2),
          ),
          side: const BorderSide(
            width: 1.5,
            color: Colors.grey,
            strokeAlign: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _defaultThumb() {
    return const Material(
      color: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
    );
  }

  double getThumbLeftOffset() {
    return (size.width - size.height) * controller.value;
  }
}

const Size _appSwitchDefaultTrackSize = Size(52.0, 24.0);
