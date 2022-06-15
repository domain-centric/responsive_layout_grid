import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

class ColumnLayoutExamplePage extends StatelessWidget {
  const ColumnLayoutExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: const Text('Column Example (resize me!)'),
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