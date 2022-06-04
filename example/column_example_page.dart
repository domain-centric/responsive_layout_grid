import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

class ColumnExamplePage extends StatelessWidget {
  const ColumnExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Column Example'),
      ),
      body: Container(
          color: Colors.yellow,
          padding: const EdgeInsets.all(8),
          child: Container(
              color: Colors.grey,
              child: ResponsiveLayoutGrid.builder(cellBuilder: _cellBuilder))));

  List<Widget> _cellBuilder(Layout layout) {
    List<Widget> children = [];
    for (int i = 0; i < layout.nrOfColumns; i++) {
      children.add(Container(
        color: Colors.blue[100],
        child: Center(
          child: Text("Column ${i + 1}"),
        ),
      ));
    }
    return children;
  }
}
