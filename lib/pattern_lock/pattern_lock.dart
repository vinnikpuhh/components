import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PatternLockCellAreaUnits {
  /// Area as a number pixels across an axis.
  /// Cell always has equal width and height.
  pixels,

  /// Area as a fraction of cell's dimension.
  /// Cell always has equal width and height.
  relative,
}

extension on PatternLockCellAreaUnits {
  // bool get isPixels => this == PatternLockCellAreaUnits.pixels;
  bool get isRelative => this == PatternLockCellAreaUnits.relative;
}

/// Within a pattern cell, there is a background area, where a pointer can
/// move without activating an cell, and there is an activation area,
/// where a pointer sets an inactive cell to active state. This enum controls
/// the general shape of this area.
enum PatternLockCellAreaShape {
  /// Activation area is a square.
  square,

  /// Activation area is a circle.
  circle
}

extension on PatternLockCellAreaShape {
//  bool get isSquare => this == PatternLockCellAreaShape.square;
  bool get isCircle => this == PatternLockCellAreaShape.circle;
}

/// Specify this to customize what counts as
/// `close enough to center of cell` for this cell to be activated.
class PatternLockCellActivationArea {
  final double dimension;
  final PatternLockCellAreaUnits units;
  final PatternLockCellAreaShape shape;

  const PatternLockCellActivationArea({
    required this.dimension,
    required this.units,
    required this.shape,
  })  : assert(
          dimension >= 0.0,
          'Activation area with size < 0 is not allowed',
        ),
        assert(
          (units == PatternLockCellAreaUnits.relative && dimension <= 1.0) ||
              units == PatternLockCellAreaUnits.pixels,
          'Relative dimension must be <= 1',
        );
}

class PatternLockLinkageSettings {
  /// Controls how far the current pattern cell can be from the last
  /// selected cell for current cell to be activated.
  ///
  /// Think of this in terms of how a knight moves in chess.
  /// This integer controls the length of the longer side of knight's movement
  /// that is considered `okay`.
  ///
  /// Let dx be x-axis difference in cell coordinates;
  /// Let dy be y-axis difference in cell coordinates;
  ///
  /// Then allowed cell coordinates are given by:
  /// math.max(dy, dx) <= [maxLinkDistance].
  ///
  /// [maxLinkDistance] = 1 allows movement in
  /// only 8 directions to adjacent cells,
  ///
  /// [maxLinkDistance] = 2 allows movement to all adjacent
  /// cells *and* like a knight in chess, and so on
  ///
  /// Horizontal, vertical, or diagonal skips are never allowed.
  final int maxLinkDistance;

  /// Whether the already activated pattern cell can be activated again from
  /// the last activated cell. Cycles (repeated connections from activated cell
  /// to another activated cell) are never allowed.
  final bool allowRepetitions;

  const PatternLockLinkageSettings({
    this.maxLinkDistance = 1,
    this.allowRepetitions = false,
  }) : assert(maxLinkDistance > 0);
}

class PatternLockLineAppearance {
  final Color color;
  final double width;

  const PatternLockLineAppearance({
    this.color = Colors.grey,
    this.width = 1.5,
  });
}

class PatternLock extends StatefulWidget {
  /// Width of pattern lock. In cells.
  final int width;

  /// Height of pattern lock. In cells.
  final int height;

  /// See [PatternLockLinkageSettings]
  final PatternLockLinkageSettings linkageSettings;

  /// Animation duration for appearing and disappearing cells and links.
  final Duration animationDuration;

  /// Called for every update. [current] is the sequence so far.
  final void Function(List<int> current)? onUpdate;

  /// Called when pointer is gone and length of [result] is greater than
  /// [minPatternLength] (i.e. called only when done on valid inputs).
  final void Function(List<int> result) onEntered;

  /// Optional builder for each of [width] * [height] cells.
  /// [position] is cell's position in the grid, counting left to right,
  /// top to bottom, * starting from 1 *.
  final Widget Function(
    BuildContext context,
    int position,
    double anim,
  )? cellBuilder;

  /// See [PatternLockCellActivationArea]
  final PatternLockCellActivationArea cellActivationArea;

  /// See [PatternLockLineAppearance]
  final PatternLockLineAppearance lineAppearance;

  /// Whether to do [HapticFeedback] on cell activation.
  final bool hapticFeedback;

  const PatternLock({
    Key? key,
    required this.width,
    required this.height,
    required this.onEntered,
    this.animationDuration = const Duration(milliseconds: 250),
    this.cellActivationArea = const PatternLockCellActivationArea(
      dimension: .7,
      units: PatternLockCellAreaUnits.relative,
      shape: PatternLockCellAreaShape.square,
    ),
    this.linkageSettings = const PatternLockLinkageSettings(
      allowRepetitions: false,
      maxLinkDistance: 1,
    ),
    this.cellBuilder,
    this.onUpdate,
    this.lineAppearance = const PatternLockLineAppearance(
      color: Colors.blue,
      width: 5.0,
    ),
    this.hapticFeedback = true,
  })  : assert(
          width > 0 && height > 0,
          'Both width and height must be not less than 1',
        ),
        super(key: key);

  @override
  PatternLockState createState() => PatternLockState();
}

class PatternLockState extends State<PatternLock>
    with TickerProviderStateMixin {
  // We can be inside of scrollable and cannot guarantee constant
  // position of lock and depend on sheer pointer positions
  final gk = GlobalKey();
  final currentPattern = <int>[];
  final cellACs = <AnimationController>[];

  AnimationController _generateNewController() {
    return AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void initState() {
    final gridSize = widget.width * widget.height;
    for (int i = 0; i < gridSize; i++) {
      cellACs.add(_generateNewController());
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternLock oldWidget) {
    if (oldWidget.height != widget.height || oldWidget.width != widget.width) {
      final newSize = widget.width * widget.height;
      final oldSize = oldWidget.width * oldWidget.height;
      final delta = newSize - oldSize;
      if (delta > 0) {
        for (int i = 0; i < delta; i++) {
          cellACs.add(_generateNewController());
        }
      } else {
        for (int i = 0; i < -delta; i++) {
          cellACs.removeLast().dispose();
        }
      }
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      for (final ac in cellACs) {
        ac.duration = widget.animationDuration;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    for (final ac in cellACs) {
      ac.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, ctrx) {
        final perCellHeight = ctrx.maxHeight / widget.height;
        final perCellWidth = ctrx.maxWidth / widget.width;
        final dim = math.min(perCellWidth, perCellHeight);
        assert(
          dim.isFinite,
          'At least one dimension should be < infinity',
        );

        return RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            _EagerPointerPositionReporter: GestureRecognizerFactoryWithHandlers<
                _EagerPointerPositionReporter>(
              () => _EagerPointerPositionReporter(),
              (_EagerPointerPositionReporter instance) {
                instance.onPointerPosition = (pos) => onContact(pos, dim);
                instance.onUp = onUp;
              },
            ),
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            key: gk,
            width: dim * widget.width,
            height: dim * widget.height,
            child: Stack(
              children: [
                if (!(widget.lineAppearance.color.alpha == 0 ||
                    widget.lineAppearance.width == 0.0))
                  Positioned.fill(
                    child: _LinkPainter(
                      animationDuration: widget.animationDuration,
                      cells: (widget.width, widget.height),
                      appearance: widget.lineAppearance,
                      cellDimension: dim,
                      pattern: currentPattern,
                    ),
                  ),
                for (int y = 0; y < widget.height; y++)
                  for (int x = 0; x < widget.width; x++)
                    () {
                      final ind = y * widget.width + x + 1;
                      final ac = cellACs[ind - 1];
                      final activeArea =
                          widget.cellActivationArea.units.isRelative
                              ? dim * widget.cellActivationArea.dimension
                              : widget.cellActivationArea.dimension;

                      return AnimatedBuilder(
                        animation: ac,
                        builder: (ctx, _) => Positioned(
                          top: dim * (y + .5) - activeArea / 2.0,
                          left: dim * (x + .5) - activeArea / 2.0,
                          height: activeArea,
                          width: activeArea,
                          child: widget.cellBuilder?.call(ctx, ind, ac.value) ??
                              _defaultCellBuilder(ctx, dim, ac.value),
                        ),
                      );
                    }(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultCellBuilder(
    BuildContext context,
    double dimension,
    double anim,
  ) {
    return LayoutBuilder(builder: (ctx, ctrx) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: widget.cellActivationArea.shape.isCircle
              ? null
              : BorderRadius.all(
                  Radius.circular(ctrx.maxHeight / 4.0),
                ),
          shape: widget.cellActivationArea.shape.isCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: Color.lerp(Colors.white, Colors.blue, anim)!,
          border: Border.all(
            width: 2.0,
            color: Colors.grey,
            strokeAlign: -1.0,
          ),
        ),
      );
    });
  }

  void onUp() {
    widget.onEntered(currentPattern);
    currentPattern.clear();
    for (final ac in cellACs) {
      ac.reverse();
    }
    setState(() {});
  }

  // expects local coords within pattern cell [0; cellDim)
  bool _isWithinCellBounds(double x, double y, double cellDim) {
    final aa = widget.cellActivationArea.units.isRelative
        ? cellDim * widget.cellActivationArea.dimension
        : widget.cellActivationArea.dimension;

    if (widget.cellActivationArea.shape.isCircle) {
      final (dx, dy) = (2.0 * x - cellDim, 2.0 * y - cellDim);
      return dx * dx + dy * dy <= aa * aa;
    } else {
      final upper = (cellDim + aa) / 2.0;
      final lower = upper - aa;
      return x < upper && x > lower && y < upper && y > lower;
    }
  }

  void onContact(Offset position, double cellDim) {
    final rb = gk.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;
    final globalOffset = rb.localToGlobal(Offset.zero);
    final rect = globalOffset & rb.size;
    if (!rect.contains(position)) return;
    position -= globalOffset;
    final (x, y) = (position.dx ~/ cellDim, position.dy ~/ cellDim);
    if (!_isWithinCellBounds(
      position.dx - x * cellDim,
      position.dy - y * cellDim,
      cellDim,
    )) return;
    if (currentPattern.isNotEmpty) {
      final last = currentPattern.last - 1;
      final (lx, ly) = (last % widget.width, last ~/ widget.width);
      final (dx, dy) = ((x - lx).abs(), (y - ly).abs());
      // horizontal, vertical, or diagonal skips are never allowed
      if (dy == 0 && dx > 1) return;
      if (dx == 0 && dy > 1) return;
      if (dy > 1 && dx > 1 && dy == dx) return;
      final max = widget.linkageSettings.maxLinkDistance;
      if (math.max(dy, dx) > max) return;
    }

    final el = y * widget.width + x + 1;
    if (!currentPattern.contains(el)) {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      currentPattern.add(el);
      widget.onUpdate?.call(currentPattern);
      cellACs[el - 1].forward();
      setState(() {});
    }
  }
}

class _LinkPainter extends StatefulWidget {
  final PatternLockLineAppearance appearance;
  final List<int> pattern;
  final Duration animationDuration;
  final double cellDimension;
  final (int, int) cells;

  const _LinkPainter({
    Key? key,
    required this.appearance,
    required this.pattern,
    required this.animationDuration,
    required this.cellDimension,
    required this.cells,
  }) : super(key: key);

  @override
  State<_LinkPainter> createState() => _LinkPainterState();
}

class _LinkPainterState extends State<_LinkPainter>
    with TickerProviderStateMixin {
  final controllers = <(int, int), AnimationController>{};

  AnimationController _generateNewController() {
    return AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void initState() {
    for (int i = 0; i < widget.pattern.length - 1; i++) {
      final curr = widget.pattern[i];
      final next = widget.pattern[i + 1];
      controllers[(curr, next)] = _generateNewController();
    }
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant _LinkPainter oldWidget) {
    if (widget.animationDuration != oldWidget.animationDuration) {
      for (final f in controllers.values) {
        f.duration = widget.animationDuration;
      }
    }

    // we either add elements to pattern or clear pattern entirely
    if (widget.pattern.isEmpty) {
      for (final f in controllers.entries) {
        f.value.reverse().then((_) {
          controllers.remove(f.key)?.dispose();
        });
      }
    } else if (widget.pattern.length > 1) {
      // looking at just penultimate and last elements is not enough
      // because we could have triggered two or more pattern cells
      // before we had a chance for a build.
      for (int i = 0; i < widget.pattern.length - 1; i++) {
        final curr = widget.pattern[i];
        final next = widget.pattern[i + 1];
        final existing = controllers[(curr, next)] ?? controllers[(next, curr)];
        if (existing == null) {
          controllers[(curr, next)] = _generateNewController();
        } else if (existing.status == AnimationStatus.reverse) {
          existing.stop();
          existing.forward();
        }
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (final ac in controllers.values) {
      ac.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinkCanvasPainter(this),
    );
  }
}

class _LinkCanvasPainter extends CustomPainter {
  final _LinkPainterState state;

  _LinkCanvasPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..strokeWidth = state.widget.appearance.width;

    for (final ac in state.controllers.entries) {
      if (ac.value.value == 0.0) continue;

      final row1 = (ac.key.$1 - 1) ~/ state.widget.cells.$1;
      final col1 = (ac.key.$1 - 1) % state.widget.cells.$1;
      final row2 = (ac.key.$2 - 1) ~/ state.widget.cells.$1;
      final col2 = (ac.key.$2 - 1) % state.widget.cells.$1;

      canvas.drawLine(
        Offset(
          (col1 + .5) * (state.widget.cellDimension),
          (row1 + .5) * (state.widget.cellDimension),
        ),
        Offset(
          (col2 + .5) * (state.widget.cellDimension),
          (row2 + .5) * (state.widget.cellDimension),
        ),
        p..color = state.widget.appearance.color.withOpacity(ac.value.value),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinkCanvasPainter oldDelegate) {
    return true;
  }
}

class _EagerPointerPositionReporter extends OneSequenceGestureRecognizer {
  int? currentPointer;

  void Function(Offset)? onPointerPosition;
  void Function()? onUp;

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (currentPointer == null) {
      currentPointer = event.pointer;
      return true;
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      onPointerPosition?.call(event.position);
      resolve(GestureDisposition.accepted);
    } else if (event is PointerUpEvent) {
      onUp?.call();
      stopTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    resolve(GestureDisposition.accepted);
    startTrackingPointer(event.pointer);
  }

  @override
  void stopTrackingPointer(int pointer) {
    super.stopTrackingPointer(pointer);
    currentPointer = null;
  }

  @override
  String get debugDescription => 'position_reporter';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
