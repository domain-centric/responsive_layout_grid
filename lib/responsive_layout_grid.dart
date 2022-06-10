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

  /// null=unlimited
  final int? maxNumberOfColumns;

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
        this.maxNumberOfColumns,

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
    this.maxNumberOfColumns,
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
            if (cell.position == CellPosition.nextRowLeftToRight ||
                cell.position == CellPosition.nextRowRightToLeft ||
                !cellLayoutBuilder.cellFitsInCurrentRow(cell)) {
              cellLayoutBuilder.goToNextRow(cell.position);
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
    goToNextRow(CellPosition.nextRowLeftToRight);
    if (colWidgets.length == 1) {
      return colWidgets.first;
    } else {
      return Column(children: colWidgets);
    }
  }

  void _addColumnGutterIfNeeded(int columnNr, List<Widget> rowChildren) {
    if (columnNr > 0) {
      var columnGutter = SizedBox(width: layoutDimensions.columnGutterWidth);
      _addToRowWidgets(columnGutter);
    }
  }

  /// returns the remaining empty columns of the current row
  int get remainingColumns => layoutDimensions.nrOfColumns - columnNr;

  // cellDirection == CellDirection.leftToRight
  // ? layoutDimensions.nrOfColumns - columnNr
  // : columnNr;

  bool cellFitsInCurrentRow(ResponsiveLayoutCell cell) =>
      cell.columnSpan.fitsFor(remainingColumns);

  void goToNextRow(CellPosition cellPosition) {
    if (rowWidgets.isNotEmpty) {
      _addRowGutterIfNeeded();
      Row row = Row(children: [
        if (layoutDimensions.marginWidth > 0)
          SizedBox(width: layoutDimensions.marginWidth),
        if (cellDirection == CellDirection.rightToLeft)
          SizedBox(
              width: (layoutDimensions.nrOfColumns - columnNr) *
                  layoutDimensions.columnWidth +
                  (layoutDimensions.nrOfColumns - columnNr) *
                      layoutDimensions.columnGutterWidth),
        ...rowWidgets,
        if (layoutDimensions.marginWidth > 0)
          SizedBox(width: layoutDimensions.marginWidth),
      ]);
      colWidgets.add(row);
      rowWidgets.clear();
    }

    determineCellDirection(cellPosition);

    // columnNr = cellDirection == CellDirection.leftToRight
    //     ? 0
    //     : layoutDimensions.nrOfColumns;
    columnNr = 0;
  }

  void determineCellDirection(CellPosition cellPosition) {
    if (cellPosition == CellPosition.nextRowLeftToRight) {
      cellDirection = CellDirection.leftToRight;
    } else if (cellPosition == CellPosition.nextRowRightToLeft) {
      cellDirection = CellDirection.rightToLeft;
    }
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
    var cellWithWidthConstraints = Container(
        constraints: BoxConstraints(maxWidth: width, minWidth: width),
        child: cell.child);

    _addToRowWidgets(cellWithWidthConstraints);

    columnNr += span;
  }

  void _addToRowWidgets(Widget widget) {
    if (cellDirection == CellDirection.leftToRight) {
      rowWidgets.add(widget);
    } else {
      rowWidgets.insert(0, widget);
    }
  }
}

/// Contains all information to build a [ResponsiveLayoutGrid]
/// It calculates the number of columns and width of these columns
/// in the available with in the [ResponsiveLayoutGrid]
class LayoutDimensions {
  late int nrOfColumns;
  late double columnWidth;

  /// the space between columns as [MaterialMeasurement]
  late double columnGutterWidth;

  /// the space between rows as [MaterialMeasurement]
  late double rowGutterHeight;

  /// the space left and right of the columns as [MaterialMeasurement]
  late double marginWidth;

  LayoutDimensions(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    columnGutterWidth = responsiveLayout.columnGutterWidth;
    rowGutterHeight = responsiveLayout.rowGutterHeight;
    nrOfColumns = _calculateNrOfColumns(responsiveLayout, availableWidth);
    marginWidth = _calculateMargin(responsiveLayout, availableWidth);
    columnWidth = _calculateColumnsWidth(availableWidth - 2 * marginWidth);
  }

  int _calculateNrOfColumns(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    if (availableWidth < responsiveLayout.minimumColumnWidth) {
      return 0;
    } else {
      var calculatedNrOfColumns = ((availableWidth + columnGutterWidth) /
          (responsiveLayout.minimumColumnWidth + columnGutterWidth))
          .truncate();
      if (responsiveLayout.maxNumberOfColumns != null &&
          calculatedNrOfColumns > responsiveLayout.maxNumberOfColumns!) {
        return responsiveLayout.maxNumberOfColumns!;
      }
      return calculatedNrOfColumns;
    }
  }

  double _calculateColumnsWidth(double availableWidth) {
    double totalColumnGuttersWidth = (nrOfColumns - 1) * columnGutterWidth;
    return (availableWidth - totalColumnGuttersWidth) / nrOfColumns;
  }

  double _calculateMargin(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    if (responsiveLayout.maxNumberOfColumns == null) {
      return 0;
    }
    if (nrOfColumns < responsiveLayout.maxNumberOfColumns!) {
      return 0;
    }
    var maxWidth = (nrOfColumns + 1) * responsiveLayout.minimumColumnWidth +
        nrOfColumns * responsiveLayout.columnGutterWidth;
    if (availableWidth < maxWidth) {
      return 0;
    } else {
      return (availableWidth - maxWidth) / 2;
    }
  }
}

enum CellPosition { nextColumn, nextRowLeftToRight, nextRowRightToLeft }

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

  const ColumnSpan.size(int columns)
      : min = columns,
        max = columns;

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
/// can fall on a 4dp baseline grid. This allows each line’s typographi