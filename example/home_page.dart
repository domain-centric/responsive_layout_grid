import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'column_example_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('$ResponsiveLayoutGrid (resize me!)'),
      ),
      body: const ButtonGrid());
}

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: ResponsiveLayoutGrid(cells: [
          _createTextBar("Examples"),
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ColumnExamplePage()));
              },
              child: const Text('Columns')),
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ColumnExamplePage()));
              },
              child: const Text('Form')),
          _createTextBar("Documentation"),
          OutlinedButton(
              onPressed: () {
                launchUrlString(
                    'https://material.io/design/layout/responsive-layout-grid.html');
              },
              child: const Text('Material Design V2')),
          OutlinedButton(
              onPressed: () {
                launchUrlString(
                    'https://m3.material.io/foundations/adaptive-design/large-screens/overview');
              },
              child: const Text('Material Design V3')),
        ]),
      );

  ResponsiveLayoutCell _createTextBar(String text) {
    return ResponsiveLayoutCell(
      columnSpan: ColumnSpan.remainingWidth(),
      child:  Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey,
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
    );
  }
}
