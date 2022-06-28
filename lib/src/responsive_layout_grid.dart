/*
 * Copyright (c) 2022. By Nils ten Hoeve. See LICENSE file in project.
 */

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Creates a [Responsive Layout Grid as defined in the Material design guidelines](https://m3.material.io/foundations/adaptive-design/large-screens)
///
/// The [ResponsiveLayoutGrid] is made up of columns and gutters,
/// providing a convenient layout structure for elements within the body region.
///
/// As the width of the body region grows or shrinks,
/// the number of grid columns and column widths changes in response.
///
/// The [ResponsiveLayoutGrid]:
///  * Has a [minimumColumnWidth]
///  * Can have a [maxNumberOfColumns]
///  * Has a [columnGutterWidth]
///  * Has a [rowGutterHeight]
///  * A [ResponsiveLayoutFactory] that determines the position of the cells.
///
///  All these can be set in the [ResponsiveLayoutGrid] constructor.
///
/// The [ResponsiveLayoutGrid] has children, named cells.
/// * Cells align with the column grid to create a logical and consistent
///   layout experience across screen sizes and orientations.
/// * Cells are [Widgets](https://docs.flutter.dev/development/ui/widgets-intro)
/// * Cells can span one or more columns
/// * Cells are separated with gutters (separation space)
///
/// It is recommended to wrap a [ResponsiveLayoutGrid] in a:
/// * [Padding] widget to add outer margins
/// * [SingleChildScrollView] widget if the cells do not fit and
///   vertical scrolling is needed.

class ResponsiveLayoutGrid extends StatelessWidget {
  /// The [minimumColumnWidth] determines the number of columns that fit
  /// in the available width and is a [MaterialMeasurement]
  final double minimumColumnWidth;

  /// The [columnGutterWidth] is the space between columns. It is a [MaterialMeasurement].
  final double columnGutterWidth;

  /// The [rowGutterHeight] is the space between rows. It is a [MaterialMeasurement].
  final double rowGutterHeight;

  /// null=unlimited
  final int? maxNumberOfColumns;

  final ResponsiveLayoutFactory layoutFactory;
  final List<Widget> children;

  static const double defaultGutter = 16;
  static const double defaultMinimumColumnWidth = 160;
  static const DefaultLayoutFactory defaultLayoutFactory =
      DefaultLayoutFactory();

  const ResponsiveLayoutGrid({
    Key? key,
    this.minimumColumnWidth = defaultMinimumColumnWidth,
    this.columnGutterWidth = defaultGutter,
    this.rowGutterHeight = defaultGutter,
    this.maxNumberOfColumns,
    this.children = const [],
    this.layoutFactory = defaultLayoutFactory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var size = Size(constraints.maxWidth, constraints.maxHeight);
      var dimensions = LayoutDimensions(this, size);
      var layout = _createLayout(dimensions);
      return RenderResponsiveLayout(
          layoutCells:
              layout._cells //TODO make sure that _cells are ordered by row
          );
    });
  }

  Layout _createLayout(LayoutDimensions dimensions) {
    if (dimensions.hasVisibleColumns) {
      return layoutFactory.create(dimensions, children);
    } else {
      return Layout.empty();
    }
  }
}


/// The [ResponsiveLayoutFactory] is responsible for creating a [Layout].
/// It orders the [children] into a Layout with a given number of columns.
///
/// The [ResponsiveLayoutGrid] uses a [DefaultLayoutFactory] by default, but
/// you could create your own [ResponsiveLayoutFactory] if you need to
/// do something outside the box.
abstract class ResponsiveLayoutFactory {
  Layout create(
    LayoutDimensions layoutDimensions,
    List<Widget> children,
  );
}

/// The [CellAlignment] can be set when a [CellPosition].nextRow is used in a
/// [ResponsiveLayoutCell]. It can be one of the following values:
/// * left: Align all cells on the left side of the row
/// * right: Align all cells on the right side of the row
/// * center: Try to align all cells in the middle of the row by
///   increasing or decreasing the [ColumnSpan] of one of the cells if needed.
/// * justify: Try to fill the row from left to right by
///   increasing or decreasing the [ColumnSpan]s of the cells if needed.

enum CellAlignment {
  /// Align all cells on the left side of the row
  left,

  /// Align all cells on the right side of the row
  right,

  /// Try to align all cells in the middle of the row by
  /// Increasing or decreasing the [ColumnSpan] of one of the cells if needed.
  center,

  /// Try to fill the row from left to right by
  /// increasing or decreasing the [ColumnSpan]s of the cells if needed.
  justify,
}

class DefaultLayoutFactory implements ResponsiveLayoutFactory {
  const DefaultLayoutFactory();

  @override
  Layout create(
    LayoutDimensions layoutDimensions,
    List<Widget> children,
  ) {
    var cellAlignment = CellAlignment.left;
    List<LayoutRow> rows = [];
    var row = LayoutRow(layoutDimensions.numberOfColumns, cellAlignment);
    rows.add(row);

    for (var cell in _cells(children)) {
      if (_startOnNewRow(cell, row)) {
        if (cell.position.type == CellPositionType.nextRow) {
          cellAlignment = cell.position.newRowAlignment!;
        }
        row = LayoutRow(layoutDimensions.numberOfColumns, cellAlignment);
        rows.add(row);
      }
      row.add(cell);
    }

    return _rowsToLayout(layoutDimensions, rows);
  }

  bool _startOnNewRow(
    ResponsiveLayoutCell cell,
    LayoutRow row,
  ) =>
      cell.position.type == CellPositionType.nextRow || !row.canAddCell(cell);

  /// Converts children by wrapping each child in a [ResponsiveLayoutCell]
  /// if it is of another type.
  List<ResponsiveLayoutCell> _cells(List<Widget> children) {
    var responsiveLayoutCells = children
        .map((widget) => widget is ResponsiveLayoutCell
            ? widget
            : ResponsiveLayoutCell(child: widget))
        .toList();
    return responsiveLayoutCells;
  }

  Layout _rowsToLayout(
      LayoutDimensions layoutDimensions, List<LayoutRow> rows) {
    var rowNr = Layout.firstRow;
    var layout = Layout(layoutDimensions);

    for (var row in rows) {
      if (row.isNotEmpty) {
        row.addToLayout(rowNr, layout);
        rowNr += 1;
      }
    }
    return layout;
  }
}

/// Holds [ResponsiveLayoutCell]s that belong to the same row but do not have a
/// final position or column span
class LayoutRow {
  final int totalColumns;
  final CellAlignment cellAlignment;

  /// cells from left to right
  final List<ResponsiveLayoutCell> _cells = [];

  /// [_cellColumnSpans] and [_cells] always correspond:
  /// _cellsColumnSpans[index] is the column span of cells[index]
  List<int> _cellColumnSpans = [];

  LayoutRow(
    this.totalColumns,
    this.cellAlignment,
  );

  bool get isNotEmpty => _cells.isNotEmpty;

  /// The number of columns that the first column must fill with emptiness
  int get _alignmentSpan {
    switch (cellAlignment) {
      case CellAlignment.right:
        return _freeColumns;
      case CellAlignment.center:
        return (_freeColumns / 2).truncate();
      default:
        return 0;
    }
  }

  add(ResponsiveLayoutCell cell) {
    _cells.add(cell);
    _optimizeColumnSpans();
  }

  /// Score for how well the cells fir the columns.
  /// The higher the score the better the fit and vise versa
  double get score {
    switch (cellAlignment) {
      case CellAlignment.justify:
        return _alignJustifiedScore + _columnSpanScore / 1000;
      case CellAlignment.center:
        return _alignCenterScore + _columnSpanScore / 1000;
      default:
        return _columnSpanScore;
    }
  }

  /// Score for how close the column spans are to the preferred column spans.
  /// * 1= all cells have their preferred column span
  /// * the lower the value= the bigger the deviation compared to the
  ///   preferred column spans
  double get _columnSpanScore {
    double score = 1;
    for (int i = 0; i < _cells.length; i++) {
      score *= _columnSpanScoreForColumn(i);
    }
    return score;
  }

  /// Score for how close the column span is to the preferred column span.
  /// * 1= the cell has the preferred column span
  /// * the lower the value= the bigger the deviation compared to the
  ///   preferred column span
  double _columnSpanScoreForColumn(int columnIndex) =>
      1 /
      ((_cells[columnIndex].columnSpan.preferred -
                  _cellColumnSpans[columnIndex])
              .abs() +
          1);

  /// Score for how well the cells can be justified:
  /// * 1= The cells cover all columns
  /// * the lower the value= the lower number of columns that are covered
  double get _alignJustifiedScore => 1 / (_freeColumns + 1);

  /// Score for how well the cells can be centered:
  /// * 1= The cells can be perfectly centered
  /// * 0.5= The cells can not be centered
  ///   e.g you cant center a [ResponsiveLayoutCell]
  ///   with a ColumnSpan.size(2) on 3 columns.
  double get _alignCenterScore =>
      (_occupiedColumns % 2) == (totalColumns % 2) ? 1 : 0.5;

  bool get _cellsFitInRow => _freeColumns >= 0;

  int get _occupiedColumns => _cellColumnSpans.reduce((a, b) => a + b);

  int get _freeColumns => totalColumns - _occupiedColumns;

  bool canAddCell(ResponsiveLayoutCell newCell) {
    List<int> columnSpansWithoutNewCell = [..._cellColumnSpans];
    var scoreWithoutNewCell = score;
    add(newCell);
    var scoreWithNewCell = score;
    var fits = _cellsFitInRow;

    _cells.removeLast();
    _cellColumnSpans = columnSpansWithoutNewCell;
    return fits & (scoreWithoutNewCell <= scoreWithNewCell);
  }

  /// Adds this [LayoutRow] to a [Layout]
  void addToLayout(int rowNr, Layout layout) {
    var columnNr = Layout.firstColumn + _alignmentSpan;

    for (int i = 0; i < _cells.length; i++) {
      var cell = _cells[i];
      var columnSpan = _cellColumnSpans[i];
      layout.addCell(
          leftColumn: columnNr,
          columnSpan: columnSpan,
          row: rowNr,
          cell: cell.child);
      columnNr += columnSpan;
    }
  }

  void _optimizeColumnSpans() {
    _cellColumnSpans = _cells.map((cell) => cell.columnSpan.preferred).toList();

    _shrinkColumnSpansToFitInRow();

    switch (cellAlignment) {
      case CellAlignment.justify:
        _growColumnSpansToJustifyRow();
        break;
      case CellAlignment.center:
        _changeColumnSpansToCenterRow();
        break;
      default:
    }
  }

  void _shrinkColumnSpansToFitInRow() {
    var occupiedColumns = _occupiedColumns;
    if (occupiedColumns <= totalColumns) {
      // It fits no need to shrink
      return;
    }
    if (_cells.length == 1) {
      // Each single cell needs to fit at least once
      _cellColumnSpans[0] = totalColumns;
      return;
    }

    var columnsToShrink = occupiedColumns - totalColumns;
    _shrinkColumnSpansProportionally(columnsToShrink);
  }

  void _shrinkColumnSpansProportionally(int columnsToShrink) {
    var nrOfColumnsCellsCanShrink = _nrOfColumnsCellsCanShrink();
    var totalNrOfColumnsCellsCanShrink =
        nrOfColumnsCellsCanShrink.reduce((a, b) => a + b);
    if (totalNrOfColumnsCellsCanShrink == 0 ||
        columnsToShrink > totalNrOfColumnsCellsCanShrink) {
      // It will not fit. do not even try
      return;
    }

    for (int i = 0; i < _cells.length; i++) {
      var factor = columnsToShrink / totalNrOfColumnsCellsCanShrink;
      var cellShrink = (nrOfColumnsCellsCanShrink[i] * factor).round();
      _cellColumnSpans[i] = _cellColumnSpans[i] - cellShrink;
      columnsToShrink -= cellShrink;
      totalNrOfColumnsCellsCanShrink -= nrOfColumnsCellsCanShrink[i];
      if (columnsToShrink == 0) {
        //done
        return;
      }
    }
  }

  void _growColumnSpansProportionally(int columnsToGrow) {
    var nrOfColumnsCellsCanGrow = _nrOfColumnsCellsCanGrow();
    var totalNrOfColumnsCellsCanGrow =
        nrOfColumnsCellsCanGrow.reduce((a, b) => a + b);
    if (totalNrOfColumnsCellsCanGrow == 0) {
      // Can not grow
      return;
    } else if (columnsToGrow > totalNrOfColumnsCellsCanGrow) {
      // can not grow more than possible
      columnsToGrow = totalNrOfColumnsCellsCanGrow;
    }

    for (int i = 0; i < _cells.length; i++) {
      var factor = columnsToGrow / totalNrOfColumnsCellsCanGrow;
      var cellGrowth = (nrOfColumnsCellsCanGrow[i] * factor).round();
      _cellColumnSpans[i] = _cellColumnSpans[i] + cellGrowth;
      columnsToGrow -= cellGrowth;
      totalNrOfColumnsCellsCanGrow -= nrOfColumnsCellsCanGrow[i];
      if (columnsToGrow == 0) {
        //done
        return;
      }
    }
  }

  void _growColumnSpansToJustifyRow() {
    var freeColumns = _freeColumns;
    if (freeColumns > 0) {
      _growColumnSpansProportionally(freeColumns);
    }
  }

  void _changeColumnSpansToCenterRow() {
    if (_alignCenterScore == 1) {
      // Center alignment is perfect, no need to grow or shrink a column span
      return;
    }
    var nrOfColumnsCellsCanGrow = _nrOfColumnsCellsCanGrow();
    if (nrOfColumnsCellsCanGrow.any((growSize) => growSize > 0)) {
      _growColumnSpanOfCellThatCanGrowTheMost(nrOfColumnsCellsCanGrow);
      return;
    }
    var nrOfColumnsCellsCanShrink = _nrOfColumnsCellsCanShrink();
    if (nrOfColumnsCellsCanShrink.any((growSize) => growSize > 0)) {
      _shrinkColumnSpanOfCellThatCanShrinkTheMost(nrOfColumnsCellsCanShrink);
      return;
    }
    // Center alignment of this row won't be perfect. Nothing we can do.
  }

  void _growColumnSpanOfCellThatCanGrowTheMost(
      List<int> nrOfColumnsCellsCanGrow) {
    var biggestGrowValue = nrOfColumnsCellsCanGrow.reduce(max);
    var indexOfCellThatCanGrowTheMost =
        nrOfColumnsCellsCanGrow.indexOf(biggestGrowValue);
    _cellColumnSpans[indexOfCellThatCanGrowTheMost]++;
  }

  void _shrinkColumnSpanOfCellThatCanShrinkTheMost(
      List<int> nrOfColumnsCellsCanShrink) {
    var biggestShrinkValue = nrOfColumnsCellsCanShrink.reduce(max);
    var indexOfCellThatCanShrinkTheMost =
        nrOfColumnsCellsCanShrink.indexOf(biggestShrinkValue);
    _cellColumnSpans[indexOfCellThatCanShrinkTheMost]--;
  }

  _nrOfColumnsCellCanGrow(int columnIndex) =>
      min(_cells[columnIndex].columnSpan.max, totalColumns) -
      _cellColumnSpans[columnIndex];

  List<int> _nrOfColumnsCellsCanGrow() {
    List<int> nrOfColumnsCellsCanGrow = [];
    for (int i = 0; i < _cells.length; i++) {
      nrOfColumnsCellsCanGrow.add(_nrOfColumnsCellCanGrow(i));
    }
    return nrOfColumnsCellsCanGrow;
  }

  _nrOfColumnsCellCanShrink(int columnIndex) {
    var columnSpan = _cells[columnIndex].columnSpan;
    if (columnSpan.preferred == ColumnSpan.remainingColumns) {
      // can not shrink wen cell needs to span the remaining columns
      return 0;
    }
    return _cellColumnSpans[columnIndex] - columnSpan.min;
  }

  List<int> _nrOfColumnsCellsCanShrink() {
    List<int> nrOfColumnsCellsCanShrink = [];
    for (int i = 0; i < _cells.length; i++) {
      nrOfColumnsCellsCanShrink.add(_nrOfColumnsCellCanShrink(i));
    }
    return nrOfColumnsCellsCanShrink;
  }
}

class LayoutCellParentData extends ContainerBoxParentData<RenderBox> {
  /// column number where the left of the cell starts in the layout
  /// [Layout.firstColumn]=first column
  int? leftColumn;

  /// column number where the right of the cell ends in the layout
  /// [Layout.firstColumn]=first column
  int? rightColumn;

  /// row number where the top of the cell starts in the layout
  /// [Layout.firstRow]=first row
  int? row;

  /// Numbers of columns that the cell spans
  int? columnSpan;

  LayoutDimensions? dimensions;
}

class LayoutCell extends ParentDataWidget<LayoutCellParentData> {
  const LayoutCell({
    Key? key,
    required this.dimensions,
    required this.leftColumn,
    required this.columnSpan,
    required this.row,
    required Widget child,
  }) : super(key: key, child: child);

  final LayoutDimensions dimensions;

  /// column number where the left of the cell starts in the layout
  /// [Layout.firstColumn]=first column
  final int leftColumn;

  /// column number where the right of the cell ends in the layout
  /// [Layout.firstColumn]=first column
  int get rightColumn => leftColumn + columnSpan - 1;

  /// row number where the top of the cell starts in the layout
  /// [Layout.firstRow]=first row
  final int row;

  /// Numbers of columns that the cell spans
  final int columnSpan;

  /// returns true is this [LayoutCell] is located on given row and column
  bool occupies({required int column, required int row}) =>
      row == this.row && column >= leftColumn && column <= rightColumn;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is LayoutCellParentData);
    final LayoutCellParentData parentData =
        renderObject.parentData! as LayoutCellParentData;
    bool needsLayout = false;

    if (parentData.dimensions != dimensions) {
      parentData.dimensions = dimensions;
      needsLayout = true;
    }

    if (parentData.leftColumn != leftColumn) {
      parentData.leftColumn = leftColumn;
      needsLayout = true;
    }

    if (parentData.row != row) {
      parentData.row = row;
      needsLayout = true;
    }

    if (parentData.columnSpan != columnSpan) {
      parentData.columnSpan = columnSpan;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Stack;
}

/// Contains the cells without margins and gutters
class Layout {
  static const int firstRow = 1;
  static const int firstColumn = 1;

  final LayoutDimensions dimensions;

  Layout(this.dimensions);

  Layout.empty() : this(LayoutDimensions.empty());

  final List<LayoutCell> _cells = [];

  int get nextRow {
    var rowNrs = _rowNrs;
    if (rowNrs.isEmpty) {
      return firstRow;
    } else {
      return rowNrs.last + 1;
    }
  }

  bool get cellsAreVisible =>
      _cells.isNotEmpty && dimensions.numberOfColumns > 0;

  addCell({
    required int leftColumn,
    required int columnSpan,
    required int row,
    required Widget cell,
  }) {
    var layoutCell = LayoutCell(
      dimensions: dimensions,
      row: row,
      leftColumn: leftColumn,
      columnSpan: columnSpan,
      child: cell,
    );
    _verifyLeftColumn(leftColumn);
    _verifyColumnSpan(leftColumn, columnSpan);
    _verifyIfPositionIsFree(layoutCell);
    _cells.add(layoutCell);
  }

  void _verifyLeftColumn(int leftColumn) {
    if (leftColumn <= 0) {
      throw ArgumentError('Must be > 0', 'leftColumn');
    }
    if (leftColumn > dimensions.numberOfColumns) {
      throw ArgumentError(
          'Must be < numberOfColumns: ${dimensions.numberOfColumns}',
          'leftColumn');
    }
  }

  void _verifyColumnSpan(int leftColumn, int columnSpan) {
    if (leftColumn + columnSpan - 1 > dimensions.numberOfColumns) {
      throw ArgumentError(
          'leftColumn + columnSpan -1 may not exceed numberOfColumns: ${dimensions.numberOfColumns}',
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

  List<LayoutCell> _cellsInRowLeftToRight(int row) {
    var cellsInRow = _cells.where((cell) => cell.row == row).toList();
    cellsInRow
        .sort((cell1, cell2) => cell1.leftColumn.compareTo(cell2.leftColumn));
    return cellsInRow;
  }


  int availableColumnsLeft(int row) {
    var cellsInRow = _cellsInRowLeftToRight(row);
    if (cellsInRow.isEmpty) {
      return dimensions.numberOfColumns;
    } else {
      return cellsInRow.first.leftColumn - 1;
    }
  }

  int availableColumnsRight(int row) {
    var cellsInRow = _cellsInRowLeftToRight(row);
    if (cellsInRow.isEmpty) {
      return dimensions.numberOfColumns;
    } else {
      return dimensions.numberOfColumns - cellsInRow.last.rightColumn;
    }
  }

  int availableColumns(int row, CellAlignment cellAlignment) =>
      cellAlignment == CellAlignment.right
          ? availableColumnsLeft(row)
          : availableColumnsRight(row);
}

/// Contains all the dimensions needed to layout a [ResponsiveLayoutGrid]
/// It calculates the number of columns and width of these columns
/// in the available with in the [ResponsiveLayoutGrid]
class LayoutDimensions {
  late int numberOfColumns;
  late double columnWidth;

  /// the space between columns as [MaterialMeasurement]
  late double columnGutterWidth;

  /// the space between rows as [MaterialMeasurement]
  late double rowGutterHeight;

  /// the space left and right of the columns as [MaterialMeasurement]
  late double marginWidth;

  late bool hasVisibleColumns;

  LayoutDimensions(ResponsiveLayoutGrid responsiveLayout, Size size) {
    columnGutterWidth = responsiveLayout.columnGutterWidth;
    rowGutterHeight = responsiveLayout.rowGutterHeight;
    numberOfColumns = _calculateNrOfColumns(responsiveLayout, size.width);
    marginWidth = _calculateMargin(responsiveLayout, size.width);
    columnWidth = _calculateColumnWidth(size.width - 2 * marginWidth);
    hasVisibleColumns = numberOfColumns > 0 && columnWidth > 0;
  }

  LayoutDimensions.empty()
      : columnGutterWidth = 0,
        rowGutterHeight = 0,
        numberOfColumns = 0,
        marginWidth = 0,
        columnWidth = 0,
        hasVisibleColumns = false;

  int _calculateNrOfColumns(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    if (availableWidth < responsiveLayout.minimumColumnWidth) {
      return 1;
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

  double _calculateColumnWidth(double availableWidth) {
    double totalColumnGuttersWidth = (numberOfColumns - 1) * columnGutterWidth;
    return (availableWidth - totalColumnGuttersWidth) / numberOfColumns;
  }

  double _calculateMargin(
      ResponsiveLayoutGrid responsiveLayout, double availableWidth) {
    if (responsiveLayout.maxNumberOfColumns == null) {
      return 0;
    }
    if (numberOfColumns < responsiveLayout.maxNumberOfColumns!) {
      return 0;
    }
    var maxWidth = (numberOfColumns + 1) * responsiveLayout.minimumColumnWidth +
        numberOfColumns * responsiveLayout.columnGutterWidth;
    if (availableWidth < maxWidth) {
      return 0;
    } else {
      return (availableWidth - maxWidth) / 2;
    }
  }

  Offset cellOffSet(int cellLeftColumn, double y) {
    var precedingColumnWidths = (cellLeftColumn - 1) * columnWidth;
    var precedingColumnGutters = (cellLeftColumn - 1) * columnGutterWidth;
    var x = marginWidth + precedingColumnWidths + precedingColumnGutters;
    return Offset(x, y);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutDimensions &&
          runtimeType == other.runtimeType &&
          numberOfColumns == other.numberOfColumns &&
          columnWidth == other.columnWidth &&
          columnGutterWidth == other.columnGutterWidth &&
          rowGutterHeight == other.rowGutterHeight &&
          marginWidth == other.marginWidth &&
          hasVisibleColumns == other.hasVisibleColumns;

  @override
  int get hashCode =>
      numberOfColumns.hashCode ^
      columnWidth.hashCode ^
      columnGutterWidth.hashCode ^
      rowGutterHeight.hashCode ^
      marginWidth.hashCode ^
      hasVisibleColumns.hashCode;
}

enum CellPositionType { nextColumn, nextRow }

/// A [ResponsiveLayoutCell] has a [CellPosition]. There are 2 types:
/// * nextColumn: The cell is to be positioned on the next available column.
///   This could be on the next row if there aren't enough empty columns
///   on the current row.
/// * nextRow: The cell is to be positioned on a new row.
///   You can set the [CellAlignment] for every new row.
class CellPosition {
  final CellPositionType type;

  /// Only has a value for the next Row
  final CellAlignment? newRowAlignment;

  const CellPosition.nextColumn()
      : type = CellPositionType.nextColumn,
        newRowAlignment = null;

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

/// You can wrap your cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)s
/// with a [ResponsiveLayoutCell] when you are using the [DefaultLayoutFactory],
/// so that you can provide the following information of the
/// cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)
/// (the [child]):
/// * [CellPosition] of the cell Widget.
/// * [ColumnSpan] of the cell Widget.
class ResponsiveLayoutCell extends StatelessWidget {
  final CellPosition position;
  final ColumnSpan columnSpan;
  final Widget child;

  const ResponsiveLayoutCell({
    Key? key,
    this.position = const CellPosition.nextColumn(),
    this.columnSpan = const ColumnSpan.size(1),
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}

/// A [ColumnSpan] tells the [DefaultLayoutFactory] how many columns a
/// [ResponsiveLayoutCell] may span.
///
/// There is a [min], [preferred] and [max] value. The [DefaultLayoutFactory]
/// will try to use these values, but may also decide to use different values
/// e.g.:
/// * When the number of available columns exceed [min] or [max]
/// * When the [CellAlignment.center] or [CellAlignment.justify] are used.
///   In these cases it is good practice to have some distance between the
///   [min], [preferred] and [max] values, so that the [DefaultLayoutFactory]
///   has some flexibility to optimize the layout.

class ColumnSpan {
  /// [min], [preferred] and [max] can have the [remainingColumns] value, to
  /// indicate that the [ColumnSpan] of a [ResponsiveLayoutCell] should take the
  /// remaining columns.
  ///
  /// We assume that [min], [preferred] and [max] values are
  /// normally below 2^32.
  static const remainingColumns = 4294967296;

  /// [min] is the minimum number of columns that the [ResponsiveLayoutCell]
  /// must span.
  ///
  /// The [DefaultLayoutFactory] will use the [min] value when
  /// positioning the [ResponsiveLayoutCell], but will use a smaller value
  /// when the number of columns of a [ResponsiveLayoutGrid] < [min].
  final int min;

  /// [preferred] is the preferred number of columns that the
  /// [ResponsiveLayoutCell] ideally spans.
  ///
  /// The [DefaultLayoutFactory] will use the [preferred] value when
  /// positioning the [ResponsiveLayoutCell], but might choose
  /// a lower or higher [ColumnSpan] when needed (see [min] and [max]).
  final int preferred;

  /// [max] is the maximum number of columns that the [ResponsiveLayoutCell]
  /// must span.
  ///
  /// The [DefaultLayoutFactory] will use the [max] value when
  /// positioning the [ResponsiveLayoutCell], but will use a smaller value
  /// when the number of columns of a [ResponsiveLayoutGrid] > [max].
  final int max;

  ColumnSpan.remainingWidth({this.min = 1, this.preferred = remainingColumns})
      : max = remainingColumns {
    validate();
  }

  ColumnSpan.max(this.max, {int? preferred})
      : min = 1,
        preferred = _defaultPreferred(1, preferred, max) {
    validate();
  }

  ColumnSpan.range({required this.min, int? preferred, required this.max})
      : preferred = _defaultPreferred(min, preferred, max) {
    validate();
  }

  const ColumnSpan.size(int columns)
      : min = columns,
        preferred = columns,
        max = columns;

  /// The rule is: 1 <= [min] <= [preferred] <= [max] <=[remainingColumns].
  void validate() {
    if (1 > min) {
      throw ArgumentError("min must be >= 1", 'min');
    }
    if (min > preferred) {
      throw ArgumentError("preferred must be >= min", 'preferred');
    }
    if (preferred > max) {
      throw ArgumentError("max must be >= preferred", 'max');
    }
    if (max > remainingColumns) {
      throw ArgumentError("max must be <= $remainingColumns", 'max');
    }
  }

  static _defaultPreferred(int min, int? preferred, int max) {
    if (min > max) {
      throw ArgumentError("min must be <= max");
    }
    if (preferred != null) {
      return preferred;
    }
    return ((max - min) / 2).round() + min;
  }

  @override
  String toString() {
    return '{$min, $preferred, $max}';
  }
}

/// Renders the [ResponsiveLayoutGrid]
class RenderResponsiveLayout extends MultiChildRenderObjectWidget {
  RenderResponsiveLayout({
    Key? key,
    List<LayoutCell> layoutCells = const [],
  }) : super(key: key, children: layoutCells);

  @override
  RenderResponsiveLayoutBox createRenderObject(BuildContext context) {
    return RenderResponsiveLayoutBox();
  }
}

/// [RenderBox] for [RenderResponsiveLayout].
/// It does all the positioning of the [LayoutCells]
class RenderResponsiveLayoutBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LayoutCellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LayoutCellParentData> {
  RenderResponsiveLayoutBox({
    List<RenderBox> children = const [],
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! LayoutCellParentData) {
      child.parentData = LayoutCellParentData();
    }
  }

  /// Helper function for calculating the intrinsics metrics of a Stack.
  static double getIntrinsicDimension(RenderBox? firstChild,
      double Function(RenderBox child) mainChildSizeGetter) {
    double extent = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;
      if (!childParentData.isPositioned) {
        extent = max(extent, mainChildSizeGetter(child));
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.biggest;
      assert(size.isFinite);
      return;
    }

    double y = 0;
    int rowNrOfPreviousCell = 0;

    RenderBox? child = firstChild;
    double highestCell = 0;
    while (child != null) {
      final LayoutCellParentData childParentData =
          child.parentData as LayoutCellParentData;

      final dimensions = childParentData.dimensions!;

      if (childParentData.row != rowNrOfPreviousCell) {
        //new row
        rowNrOfPreviousCell = childParentData.row!;
        if (highestCell > 0) {
          y += dimensions.rowGutterHeight;
        }
        y += highestCell;
        highestCell = 0;
      }

      var cellWidth = _cellWidth(childParentData, dimensions);
      child.layout(BoxConstraints(minWidth: cellWidth, maxWidth: cellWidth),
          parentUsesSize: true);
      childParentData.offset =
          dimensions.cellOffSet(childParentData.leftColumn!, y);
      highestCell = max(highestCell, child.size.height);

      child = childParentData.nextSibling;
    }

    size = Size(constraints.biggest.width, y + highestCell);
  }

  double _cellWidth(
      LayoutCellParentData childParentData, LayoutDimensions dimensions) {
    return childParentData.columnSpan! * dimensions.columnWidth +
        (childParentData.columnSpan! - 1) * dimensions.columnGutterWidth;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
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
/// can fall on a 4dp baseline grid. This allows each line’s typography
class MaterialMeasurement {}
