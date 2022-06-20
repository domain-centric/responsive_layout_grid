import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

class ColumnsExamplePage extends StatelessWidget {
  const ColumnsExamplePage({Key? key}) : super(key: key);
  static const title='Columns';
  //TODO update to correct demo project and source code file;
  static const urlToSourceCode='https://github.com/domain-centric/responsive_layout_grid';

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: const Text('$title Example (resize me!)'),
          ),
          body: Container(
              color: Colors.yellow,
              padding: const EdgeInsets.all(8),
              child: Container(
                  color: Colors.grey,
                  child: ResponsiveLayoutGrid(
                    layoutFactory: MyLayoutFactory(),
                    maxNumberOfColumns: 6,
                  ))));


}

/// A custom [ResponsiveLayoutFactory] to create the exact number of
/// [LayoutCell]s as available number of columns
class MyLayoutFactory extends ResponsiveLayoutFactory {
  @override
  Layout create(int numberOfColumns, List<Widget> children) {
    var layout = Layout(numberOfColumns);
    for (int i = 1; i <= numberOfColumns; i++) {
      layout.addCell(leftColumn: i, columnSpan: 1, row: 1, cell: Container(
        color: Colors.white,
        child: Center(
          child: Text("Column $i"),
        ),
      ));
    }
    return layout;
  }
}