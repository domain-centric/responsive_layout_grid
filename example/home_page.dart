import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'column_example_page.dart';
import 'form_example_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: Text('$ResponsiveLayoutGrid (resize me!)'),
          ),
          body: const ButtonGrid());
}

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ResponsiveLayoutGrid(
              maxNumberOfColumns: 4,
              cells: [
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  columnSpan: ColumnSpan.remainingWidth(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey,
                    child: const Text("Examples",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  const ColumnExamplePage()));
                      },
                      child: const Text('Columns')),
                ),
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  const FormExamplePage()));
                      },
                      child: const Text('Form')),
                ),
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  columnSpan: ColumnSpan.remainingWidth(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey,
                    child: const Text("Documentation",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  child: OutlinedButton(
                      onPressed: () {
                        launchUrlString(
                            'https://material.io/design/layout/responsive-layout-grid.html');
                      },
                      child: const Text('Material Design V2')),
                ),
                ResponsiveLayoutCell(
                  position: CellPosition.nextRow,
                  child: OutlinedButton(
                      onPressed: () {
                        launchUrlString(
                            'https://m3.material.io/foundations/adaptive-design/large-screens/overview');
                      },
                      child: const Text('Material Design V3')),
                ),
              ]),
        ),
      );

}

