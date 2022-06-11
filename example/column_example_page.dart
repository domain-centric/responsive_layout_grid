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
                  child: ResponsiveLayoutGrid.builder(
                    cellFactory: MyCellFactory(),
                    maxNumberOfColumns: 6,
                  ))));


}

class MyCellFactory extends ResponsiveLayoutCellFactory {
  @override
  List<Widget> create(LayoutDimensions layoutDimensions) {
    List<Widget> cells = [];
    for (int i = 0; i < layoutDimensions.nrOfColumns; i++) {
      cells.add(Container(
        color: Colors.white,
        child: Center(
          child: Text("Column ${i + 1}"),
        ),
      ));
    }
    return cells;
  }

}