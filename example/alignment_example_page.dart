import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

import 'random.dart';
import 'scroll_view_with_scroll_bar.dart';


class AlignmentExamplePage extends StatelessWidget {
  const AlignmentExamplePage({Key? key}) : super(key: key);
  static const title='Alignment';
  //TODO update to correct demo project and source code file;
  static const urlToSourceCode='https://github.com/domain-centric/responsive_layout_grid';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('$title Example (resize me!)'),
      ),
      body: ScrollViewWithScrollBar(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: ResponsiveLayoutGrid(
              maxNumberOfColumns: 6,
              children: [
                ..._createCells('right', CellAlignment.right, Colors.yellow),
                ..._createCells('left', CellAlignment.left, Colors.green),
                ..._createCells('center', CellAlignment.center, Colors.orange),
                ..._createCells(
                    'justify', CellAlignment.justify, Colors.blue),
              ],
            )),
      ));

  List<ResponsiveLayoutCell> _createCells(
      String text, CellAlignment cellAlignment, MaterialColor color) {
    List<ResponsiveLayoutCell> cells = [];
    cells.add(_createGroupBar(cellAlignment, text, color));

    for (int i = 0; i < 10; i++) {
      var min = 1;
      var preferred = min + randomInt(min: 0, max: 3);
      var max = preferred + randomInt(min: 0, max: 3);
      cells.add(_createCell(min, preferred, max, color));
    }
    return cells;
  }

  ResponsiveLayoutCell _createCell(
      int min, int preferred, int max, MaterialColor color) {
    return ResponsiveLayoutCell(
      position: const CellPosition.nextColumn(),
      columnSpan: ColumnSpan.range(min: min, preferred: preferred, max: max),
      child: Container(
        color: color,
        child: Center(child: Text("min: $min, pref.: $preferred, max: $max")),
      ),
    );
  }

  ResponsiveLayoutCell _createGroupBar(
    CellAlignment cellAlignment,
    String text,
    MaterialColor color,
  ) {
    return ResponsiveLayoutCell(
      position: CellPosition.nextRow(cellAlignment),
      columnSpan: ColumnSpan.remainingWidth(),
      child: Container(
        color: color,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text.toUpperCase()),
        )),
      ),
    );
  }
}
