import 'package:flutter/material.dart';

/// Creates a [Responsive Layout Grid as defined in Material design](https://m3.material.io/foundations/adaptive-design/large-screens)
/// Wrap this widget in a [Padding] widget to set outer margins
/// Wrap this widget in a [SingleChildScrollView] if you need scrolling

class ResponsiveLayoutGrid extends StatefulWidget {
  /// The [minimumColumnWidth] determines the number of columns that fit
  /// in the available width and is a [MaterialMeasurement]
  final double minimumColumnWidth;

  /// The [columnGutterWidth] is the space between columns. It is a [MaterialMeasurement].
  final double columnGutterWidth;

  /// The [rowGutterHeight] is the space between rows. It is a [MaterialMeasurement].
  final double rowGutterHeight;

  /// A [cellBuilder] is a function that creates [Widget]s that represent the cells.
  /// The function can use information of the size and position of the [Column]s
  ///
  /// The [cells] (children) are the widgets that are displayed by this [ResponsiveLayoutGrid].
  /// [cells] are often [Widgets] that are wrapped in a [ResponsiveLayoutCell]
  /// [cells] that are not wrapped will automatically be wrapped in a [ResponsiveLayoutCell] later
  late List<Widget> Function(LayoutDimensions layoutDimensions) cellBuilder;

  static const double defaultGutter = 16;
  static const double defaultColumnWidth = 160;

  ResponsiveLayoutGrid(
      {Key? key,
      this.minimumColumnWidth = defaultColumnWidth,
      this.columnGutterWidth = defaultGutter,
      this.rowGutterHeight = defaultGutter,

      /// The [cells] (children) are the widgets that are displayed by this [ResponsiveLayout].
      /// [cells] are often [Widgets] that are wrapped in a [ResponsiveLayoutCell]
      /// [cells] that are not wrapped will automatically be wrapped in a [ResponsiveLayoutCell] later
      required List<Widget> cells})
      : cellBuilder = _createDefaultCellBuilder(cells),
        super(key: key);

  /// Lets you build different layouts using a [cellBuilder];
  ResponsiveLayoutGrid.builder({
    Key? key,
    this.minimumColumnWidth = defaultColumnWidth,
    this.columnGutterWidth = defaultGutter,
    this.rowGutterHeight = defaultGutter,
    required this.cellBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResponsiveLayoutGrid();

  static List<Widget> Function(LayoutDimensions layoutDimensions)
      _createDefaultCellBuilder(List<Widget> cells) =>
          (layoutDimensions) => cells;
}

class _ResponsiveLayoutGrid extends State<ResponsiveLayoutGrid> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      LayoutDimensions layoutDimensions =
          LayoutDimensions(widget, constraints.maxWidth);

      var cellLayoutBuilder = CellLayoutBuilder(layoutDimensions);
      for (ResponsiveLayoutCell cell in cells(layoutDimensions)) {
        if (cell.position == CellPosition.nextRow ||
            !cellLayoutBuilder.cellFitsInCurrentRow(cell)) {
          cellLayoutBuilder.goToNextRow();
        }
        cellLayoutBuilder.addCell(cell);
      }
      return cellLayoutBuilder.build();
    });
  }

  List<ResponsiveLayoutCell> cells(LayoutDimensions layoutDimensions) {
    var widgets = widget.cellBuilder(layoutDimensions);
    var responsiveLayoutCells = widgets
        .map((widget) => widget is ResponsiveLayoutCell
            ? widget
            : ResponsiveLayoutCell(child: widget))
        .toList();
    return responsiveLayoutCells;
  }
}

enum CellDirection { leftToRight, rightToLeft }

class CellLayoutBuilder {
  /// containing the rows and row gutters
  final List<Widget> colWidgets = [];

  /// containing the cell and column gutters
  final List<Widget> rowWidgets = [];
  final LayoutDimensions layoutDimensions;
  CellDirection cellDirection = CellDirection.leftToRight;
  int columnNr = 0;

  CellLayoutBuilder(this.layoutDimensions);

  Widget build() {
    _addLastRowIfNeeded();
    if (colWidgets.length == 1) {
      return colWidgets.first;
    } else {
      return Column(children: colWidgets);
    }
  }

  void _addLastRowIfNeeded() {
    if (rowWidgets.isNotEmpty) {
      goToNextRow();
    }
  }

  void _addColumnGutterIfNeeded(int columnNr, List<Widget> rowChildren) {
    if (columnNr > 0) {
      var columnGutter = SizedBox(width: layoutDimensions.columnGutterWidth);
      rowChildren.add(columnGutter);
    }
  }

  /// returns the remaining empty columns of the current row
  int get remainingColumns => cellDirection == CellDirection.leftToRight
      ? layoutDimensions.nrOfColumns - columnNr
      : columnNr;

  bool cellFitsInCurrentRow(ResponsiveLayoutCell cell) =>
      cell.columnSpan.fitsFor(remainingColumns);

  void goToNextRow() {
    _addRowGutterIfNeeded();
    Row row = Row(children: [...rowWidgets]);
    colWidgets.add(row);
    rowWidgets.clear();
    columnNr = cellDirection == CellDirection.leftToRight
        ? 0
        : layoutDimensions.nrOfColumns;
  }

  void _addRowGutterIfNeeded() {
    if (colWidgets.isNotEmpty) {
      var rowGutter = SizedBox(height: layoutDimensions.rowGutterHeight);
      colWidgets.add(rowGutter);
    }
  }

  void addCell(ResponsiveLayoutCell cell) {
    var span = cell.columnSpan.spanFor(remainingColumns);
    var width = span * layoutDimensions.columnWidth +
        (span - 1) * layoutDimensions.columnGutterWidth;

    _addColumnGutterIfNeeded(columnNr, rowWidgets);
    var cellWithWidthContraints = Container(
        constraints: BoxConstraints(maxWidth: width, minWidth: width),
        child: cell.child);
    rowWidgets.add(cellWithWidthContraints);
    columnNr += span;
  }
}

/// Contains all information to build a [ResponsiveLayoutGrid]
/// It calculates the number of columns and width of these columns
/// in the available with in the [ResponsiveLayoutGrid]
class LayoutDimensions {
  late int nrOfColumns;
  late double columnWidth;
  late double columnGutterWidth;
  late double rowGutterHeight;

  LayoutDimensions(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    columnGutterWidth = responsiveLayout.columnGutterWidth;
    rowGutterHeight = responsiveLayout.rowGutterHeight;
    nrOfColumns = _calculateNrOfColumns(responsiveLayout, availableWidth);
    columnWidth = _calculateColumnsWidth(availableWidth);
  }

  int _calculateNrOfColumns(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    if (availableWidth < responsiveLayout.minimumColumnWidth) {
      return 0;
    } else {
      return ((availableWidth + columnGutterWidth) /
              (responsiveLayout.minimumColumnWidth + columnGutterWidth))
          .truncate();
    }
  }

  double _calculateColumnsWidth(double availableWidth) {
    double totalColumnGuttersWidth = (nrOfColumns - 1) * columnGutterWidth;
    return (availableWidth - totalColumnGuttersWidth) / nrOfColumns;
  }
}

enum CellPosition { nextColumn, nextRow }

class ResponsiveLayoutCell extends StatelessWidget {
  final CellPosition position;
  final ColumnSpan columnSpan;
  final Widget child;

  const ResponsiveLayoutCell({
    Key? key,
    this.position = CellPosition.nextColumn,
    this.columnSpan = const ColumnSpan.auto(),
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

//
// // A wrapper for a child inside its parent ((ResponsiveLayoutGrid) in order to provide extra layout information
// ResponsiveLayoutChild
// topLeft: nextRow/ nextColumn    (nextColumn byDefault)
// columnSpan: ColumnSpan.max(n), ColumnSpan.auto(), ColumnSpan.remainingWidth()  (auto by default, auto=minimum space of child)
// child:
//
// // A ResponsiveLayoutChild that creates a child uses the column information from its parent (ResponsiveLayoutGrid)
// ResponsiveLayoutChildFactory extends ResponsiveLayoutChild
// topLeft: nextRow/ nextColumn    (nextColumn byDefault)
// columnSpan: ColumnSpan.max(n), ColumnSpan.auto(), ColumnSpan.remainingWidth()  (auto by default, auto=minimum space of child)
// builder: Widget Function(ResponsiveLayoutChildContext context)
//
//
// See:
// https://m3.material.io/foundations/adaptive-design/large-screens
// https://material.io/design/layout/responsive-layout-grid.html
// https://material.io/design/layout/responsive-layout-grid.html#breakpoints
//
// https://pub.dev/packages/responsive_grid
// https://medium.com/flutter-community/build-your-responsive-flutter-layout-like-a-pro-6bf86aaed81e
//

class ColumnSpan {
  /// a constant value to indicate that the [max] is calculated based on the
  /// minimum required width of the [ResponsiveLayoutCell]
  static const int automatic = -1;

  /// [min] number of columns that the [ResponsiveLayoutCell] must span
  /// [min] must be < [max].
  /// The [ResponsiveLayoutCell] will be put on the next row
  /// when [min] > remaining columns.
  /// Note that the [ColumnSpan] will be smaller
  /// when the number of columns of [ResponsiveLayoutGrid] > [min].
  final int min;

  /// [max] number of columns that the [Widget] must span.
  /// [max] must be > [min].
  /// Note that the [ColumnSpan] will be smaller
  /// when the number of columns of [ResponsiveLayoutGrid] > [max].
  /// * When [max] = null it means infinite (=the remaining available columns
  ///   in [ResponsiveLayoutGrid];
  /// * When [max] is [automatic] it means the [ColumnSpan] is calculated based
  ///   on the minimum required width of the [ResponsiveLayoutCell]
  final int? max;

  ColumnSpan.remainingWidth([this.min = 1]) : max = null {
    validateMinMax();
  }

  ColumnSpan.max(this.max) : min = 1 {
    validateMinMax();
  }

  ColumnSpan.range(this.min, this.max) {
    validateMinMax();
  }

  /// The [ColumnSpan] is calculated based on the minimum width of
  /// the [ResponsiveLayoutCell]
  const ColumnSpan.auto()
      : min = 1,
        max = automatic;

  void validateMinMax() {
    if (max == automatic) {
      if (min != 1) {
        throw Exception(
            "The min value must be 1 when you are using an automatic $ColumnSpan");
      }
    } else {
      if (min < 1) {
        throw Exception("The min value must be > 1");
      }
      if (max != null && min > max!) {
        throw Exception("The min value must be < max");
      }
    }
  }

  bool fitsFor(int remainingColumns) => min <= remainingColumns;

  /// returns the number of columns based on the remaining number of columns
  int spanFor(int remainingColumns) {
    if (max == null) {
      return remainingColumns;
    }
    if (max == automatic) {
      return 1; // TODO calculate
    }
    if (max! > remainingColumns) {
      return remainingColumns;
    } else {
      return max!;
    }
  }
}

/// Distances in flutter are in
/// [Density-independent Pixels](https://en.wikipedia.org/wiki/Device-independent_pixel)
///
/// To ensure that Material Design layouts are visually balanced,
/// most measurements align to 8dp, which corresponds to both spacing and the
/// overall layout.
/// Components are sized in 8dp increments, ensuring a consistent visual
/// rhythm across each screen.
///
/// Smaller elements, such as icons, can align to a 4dp grid, while typography
/// can fall on a 4dp baseline grid. This allows each line’s typographic
/// baseline to be spaced in increments of 4dp from a neighbor.
class MaterialMeasurement {}
