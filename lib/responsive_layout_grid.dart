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

  /// A [cellFactory] is a function that creates [Widget]s that represent the cells.
  /// The function can use information of the size and position of the [Column]s
  ///
  /// The [cells] (children) are the widgets that are displayed by this [ResponsiveLayoutGrid].
  /// [cells] are often [Widgets] that are wrapped in a [ResponsiveLayoutCell]
  /// [cells] that are not wrapped will automatically be wrapped in a [ResponsiveLayoutCell] later
  late ResponsiveLayoutCellFactory cellFactory;
  final ResponsiveLayoutFactory layoutFactory;

  static const double defaultGutter = 16;
  static const double defaultColumnWidth = 160;
  static const DefaultLayoutFactory defaultLayoutFactory =
      DefaultLayoutFactory();

  ResponsiveLayoutGrid({
    Key? key,
    this.minimumColumnWidth = defaultColumnWidth,
    this.columnGutterWidth = defaultGutter,
    this.rowGutterHeight = defaultGutter,
    this.maxNumberOfColumns,

    /// The [cells] (children) are the widgets that are displayed by this [ResponsiveLayout].
    /// [cells] are often [Widgets] that are wrapped in a [ResponsiveLayoutCell]
    /// [cells] that are not wrapped will automatically be wrapped in a [ResponsiveLayoutCell] later
    required List<Widget> cells,
    this.layoutFactory = defaultLayoutFactory,
  })  : cellFactory = DefaultCellFactory(cells),
        super(key: key);

  /// Lets you build different layouts using a [cellFactory];
  ResponsiveLayoutGrid.builder({
    Key? key,
    this.minimumColumnWidth = defaultColumnWidth,
    this.columnGutterWidth = defaultGutter,
    this.rowGutterHeight = defaultGutter,
    this.maxNumberOfColumns,
    this.layoutFactory = defaultLayoutFactory,
    required this.cellFactory,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResponsiveLayoutGrid();
}

class _ResponsiveLayoutGrid extends State<ResponsiveLayoutGrid> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var layoutDimensions = LayoutDimensions(widget, constraints.maxWidth);
      var nrOfColumns = layoutDimensions.nrOfColumns;
      var layoutFactory = widget.layoutFactory;
      var layout = layoutFactory.create(nrOfColumns, cells(layoutDimensions));
      return layout.asWidget(layoutDimensions);
    });
  }

  List<ResponsiveLayoutCell> cells(LayoutDimensions layoutDimensions) {
    var widgets = widget.cellFactory.create(layoutDimensions);
    var responsiveLayoutCells = widgets
        .map((widget) => widget is ResponsiveLayoutCell
            ? widget
            : ResponsiveLayoutCell(child: widget))
        .toList();
    return responsiveLayoutCells;
  }
}

/// A [ResponsiveLayoutCellFactory] creates [Widget]s that represent the cells.
/// The [create] method can use information of the size and position of the [Column]s
///
/// The [cells] are the [Widgets] that are displayed by this [ResponsiveLayoutGrid].
/// [cells] are often [Widgets] that are wrapped in a [ResponsiveLayoutCell]
/// [cells] that are not wrapped will automatically be wrapped in a [ResponsiveLayoutCell] later
abstract class ResponsiveLayoutCellFactory {
  List<Widget> create(LayoutDimensions layoutDimensions);
}

class DefaultCellFactory implements ResponsiveLayoutCellFactory {
  final List<Widget> cells;

  DefaultCellFactory(this.cells);

  @override
  List<Widget> create(LayoutDimensions layoutDimensions) => cells;
}

abstract class ResponsiveLayoutFactory {
  Layout create(
    int numberOfColumns,
    List<ResponsiveLayoutCell> responsiveLayoutCells,
  );
}

enum ColumnSpanPreference {
  /// Try to give the cells a column span that is
  /// as narrow (close to min) as possible
  closeToMin,

  /// Try to give the cells a column span that is
  /// somewhere between min and max
  betweenMinAndMax,

  /// Try to give the cells a column span that is
  /// as wide (close to max) as possible
  closeToMax
}

enum CellAlignment {
  /// Align all cells on the left side of the row
  left,

  /// Align all cells on the right side of the row
  right,

  /// Try to fill the row from left to right
  /// by increasing or decreasing the [ColumnSpan] of the cells.
  justified
}

class DefaultLayoutFactory implements ResponsiveLayoutFactory {
  const DefaultLayoutFactory();

  @override
  Layout create(
    int numberOfColumns,
    List<ResponsiveLayoutCell> cells,
  ) {
    var cellAlignment = CellAlignment.left;
    var layout = Layout(numberOfColumns);
    var row = Layout.firstRow;
    var column = Layout.firstColumn;
    for (var cell in cells) {
      if (_startOnNewRow(cell, layout.availableColumns(row, cellAlignment))) {
        _addAlignmentCellIfNeeded(
            layout: layout,
            row: row,
            column: column,
            cellAlignment: cellAlignment);

        if (cell.position.type == CellPositionType.nextRow) {
          cellAlignment = cell.position.newRowAlignment!;
        }
        row = layout.nextRow;
        column = _nextRowColumnNumber(cellAlignment, numberOfColumns);
      }

      var columnSpan =
          cell.columnSpan.spanFor(layout.availableColumns(row, cellAlignment));
      var leftColumn = cellAlignment == CellAlignment.right
          ? column - columnSpan + 1
          : column;
      layout.addCell(
        row: row,
        leftColumn: leftColumn,
        columnSpan: columnSpan,
        cell: cell,
      );

      if (cellAlignment == CellAlignment.right) {
        column = leftColumn - 1;
      } else {
        column += columnSpan;
      }
    }
    _addAlignmentCellIfNeeded(
      layout: layout,
      row: row,
      column: column,
      cellAlignment: cellAlignment,
    );

    return layout;
  }

  int _nextRowColumnNumber(CellAlignment cellAlignment, int numberOfColumns) {
    return cellAlignment == CellAlignment.right
        ? numberOfColumns
        : Layout.firstColumn;
  }

  bool _startOnNewRow(
    ResponsiveLayoutCell cell,
    int availableColumns,
  ) =>
      cell.position.type == CellPositionType.nextRow ||
      !cell.columnSpan.fitsFor(availableColumns);

  ///TODO remove when ResponsiveLayoutGrid uses CustomMultiChildLayout with MultiChildLayoutDelegate
  void _addAlignmentCellIfNeeded({
    required Layout layout,
    required int row,
    required int column,
    required CellAlignment cellAlignment,
  }) {
    if (cellAlignment == CellAlignment.right) {
      var availableColumns = layout.availableColumns(row, cellAlignment);
      if (availableColumns > 0 && availableColumns < layout.numberOfColumns) {
        layout.addCell(
            leftColumn: Layout.firstColumn,
            columnSpan: availableColumns,
            row: row,
            cell: const ResponsiveLayoutCell(child: SizedBox()));
      }
    }
  }
}

class LayoutCell {
  /// column number where the left of the cell starts in the layout
  /// [Layout.firstColumn]=first column
  final int leftColumn;

  /// column number where the right of the cell ends in the layout
  /// [Layout.firstColumn]=first column
  final int rightColumn;

  /// row number where the top of the cell starts in the layout
  /// [Layout.firstRow]=first row
  final int row;

  /// Numbers of columns that the cell spans
  final int columnSpan;

  /// Contains all information on how to display the cell
  final ResponsiveLayoutCell cell;

  LayoutCell({
    required this.leftColumn,
    required this.columnSpan,
    required this.row,
    required this.cell,
  }) : rightColumn = leftColumn + columnSpan - 1;

  /// Creates a widget that represents a cell with width constrains
  Widget asWidget(LayoutDimensions layoutDimensions) {
    var width = columnSpan * layoutDimensions.columnWidth +
        (columnSpan - 1) * layoutDimensions.columnGutterWidth;
    return Container(
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      child: cell.child,
    );
  }

  /// returns true is this [LayoutCell] is located on given row and column
  bool occupies({required int column, required int row}) =>
      row == this.row && column >= leftColumn && column <= rightColumn;
}

class LayoutRow {
  /// [LayoutCell]s from left to right
  final List<LayoutCell> cells;

  LayoutRow(this.cells);

  /// Creates a widget that represents a row: margin, cells, margin
  Widget asWidget(LayoutDimensions layoutDimensions) {
    List<Widget> widgets = [];

    for (var cell in cells) {
      if (widgets.isNotEmpty) {
        widgets.add(_createColumnGutter(layoutDimensions.columnGutterWidth));
      }
      widgets.add(cell.asWidget(layoutDimensions));
    }

    var marginWidth = layoutDimensions.marginWidth;
    if (marginWidth > 0) {
      widgets.insert(0, _createMargin(marginWidth));
      widgets.add(_createMargin(marginWidth));
    }

    return Row(children: widgets);
  }

  Widget _createMargin(double width) => SizedBox(width: width);

  Widget _createColumnGutter(double width) => SizedBox(width: width);
}

/// Contains the cells without margins and gutters
class Layout {
  static const int firstRow = 1;
  static const int firstColumn = 1;

  final int numberOfColumns;

  Layout(this.numberOfColumns);

  final List<LayoutCell> _cells = [];

  int get nextRow {
    var rowNrs = _rowNrs;
    if (rowNrs.isEmpty) {
      return firstRow;
    } else {
      return rowNrs.last + 1;
    }
  }

  addCell({
    required int leftColumn,
    required int columnSpan,
    required int row,
    required ResponsiveLayoutCell cell,
  }) {
    var layoutCell = LayoutCell(
        row: row, leftColumn: leftColumn, columnSpan: columnSpan, cell: cell);
    _verifyLeftColumn(leftColumn);
    _verifyColumnSpan(leftColumn, columnSpan);
    _verifyIfPositionIsFree(layoutCell);
    _cells.add(layoutCell);
  }

  /// Creates a widget that represents the layout with rows and cells
  Widget asWidget(LayoutDimensions layoutDimensions) {
    if (_cells.isEmpty) {
      return _createEmptyWidget();
    } else {
      return _createWidgetWithCellsMarginsAndGutters(layoutDimensions);
    }
  }

  Widget _createEmptyWidget() => const SizedBox();

  Widget _createWidgetWithCellsMarginsAndGutters(
      LayoutDimensions layoutDimensions) {
    var rows = _rows;
    if (rows.length == 1) {
      return rows.first.asWidget(layoutDimensions);
    }

    List<Widget> widgets = [];
    for (var row in rows) {
      if (row.cells.isNotEmpty) {
        if (widgets.isNotEmpty) {
          widgets.add(_createRowGutter(layoutDimensions));
        }
        widgets.add(row.asWidget(layoutDimensions));
      }
    }
    return Column(children: widgets);
  }

  Widget _createRowGutter(LayoutDimensions layoutDimensions) =>
      SizedBox(height: layoutDimensions.rowGutterHeight);

  void _verifyLeftColumn(int leftColumn) {
    if (leftColumn <= 0) {
      throw ArgumentError('Must be > 0', 'leftColumn');
    }
    if (leftColumn > numberOfColumns) {
      throw ArgumentError(
          'Must be < numberOfColumns: $numberOfColumns', 'leftColumn');
    }
  }

  void _verifyColumnSpan(int leftColumn, int columnSpan) {
    if (leftColumn + columnSpan - 1 > numberOfColumns) {
      throw ArgumentError(
          'leftColumn + columnSpan -1 may not exceed numberOfColumns: $numberOfColumns',
          'columnSpan');
    }
  }

  void _verifyIfPositionIsFree(LayoutCell layoutCell) {
    int row = layoutCell.row;
    for (int column = layoutCell.leftColumn;
        column < layoutCell.rightColumn;
        column++) {
      if (hasCell(row, column)) {
        throw ArgumentError(
            'Cell with row: $row and column:$column already has a cell');
      }
    }
  }

  bool hasCell(int row, int column) =>
      _cells.any((cell) => cell.occupies(column: column, row: row));

  List<int> get _rowNrs {
    var rowNrs = _cells.map((cell) => cell.row).toSet().toList();
    rowNrs.sort();
    return rowNrs;
  }

  LayoutRow _row(int row) => LayoutRow(_cellsInRowLeftToRight(row));

  List<LayoutCell> _cellsInRowLeftToRight(int row) {
    var cellsInRow = _cells.where((cell) => cell.row == row).toList();
    cellsInRow
        .sort((cell1, cell2) => cell1.leftColumn.compareTo(cell2.leftColumn));
    return cellsInRow;
  }

  List<LayoutRow> get _rows {
    List<LayoutRow> rows = [];
    for (int rowNr in _rowNrs) {
      rows.add(_row(rowNr));
    }
    return rows;
  }

  int availableColumnsLeft(int row) {
    var cellsInRow = _cellsInRowLeftToRight(row);
    if (cellsInRow.isEmpty) {
      return numberOfColumns;
    } else {
      return cellsInRow.first.leftColumn - 1;
    }
  }

  int availableColumnsRight(int row) {
    var cellsInRow = _cellsInRowLeftToRight(row);
    if (cellsInRow.isEmpty) {
      return numberOfColumns;
    } else {
      return numberOfColumns - cellsInRow.last.rightColumn;
    }
  }

  int availableColumns(int row, CellAlignment cellAlignment) =>
      cellAlignment == CellAlignment.right
          ? availableColumnsLeft(row)
          : availableColumnsRight(row);
}

// enum CellDirection { leftToRight, rightToLeft }

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

enum CellPositionType { nextColumn, nextRow }

class CellPosition {
  final CellPositionType type;

  /// Only has a value for the next Row
  final CellAlignment? newRowAlignment;

  /// The cell is to be positioned on the next available column.
  /// This could be on the next row if there aren't enough empty columns
  /// on the current row.
  const CellPosition.nextColumn()
      : type = CellPositionType.nextColumn,
        newRowAlignment = null;

  /// The cell is to be positioned on a new row at the bottom.
  /// [newRowAlignment] sets the alignment for this new row.
  const CellPosition.nextRow([this.newRowAlignment = CellAlignment.left])
      : type = CellPositionType.nextRow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          newRowAlignment == other.newRowAlignment;

  @override
  int get hashCode => type.hashCode ^ newRowAlignment.hashCode;
}

class ResponsiveLayoutCell extends StatelessWidget {
  final CellPosition position;
  final ColumnSpan columnSpan;
  final Widget child;

  const ResponsiveLayoutCell({
    Key? key,
    this.position = const CellPosition.nextColumn(),
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

  bool fitsFor(int availableColumns) {
    return min <= availableColumns;
  }

  /// returns the number of columns based on the remaining number of columns
  int spanFor(int availableColumns) {
    if (max == null) {
      return availableColumns;
    }
    if (max == automatic) {
      return 1; // TODO calculate
    }
    if (max! > availableColumns) {
      return availableColumns;
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
