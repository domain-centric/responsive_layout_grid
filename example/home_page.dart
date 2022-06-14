import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'column_example_page.dart';
import 'form_example_page.dart';
import 'news_example_page.dart';
import 'scroll_view_with_scroll_bar.dart';

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
  Widget build(BuildContext context) => ScrollViewWithScrollBar(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ResponsiveLayoutGrid(maxNumberOfColumns: 4, cells: [
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              columnSpan: ColumnSpan.remainingWidth(),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey,
                child: const Text("Examples",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ColumnLayoutExamplePage()));
                  },
                  child: const Text('Column Layout')),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const FormLayoutExamplePage()));
                  },
                  child: const Text('Form Layout')),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NewsLayoutExamplePage()));
                  },
                  child: const Text('News Layout')),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              columnSpan: ColumnSpan.remainingWidth(),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey,
                child: const Text("Documentation",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
              child: OutlinedButton(
                  onPressed: () {
                    launchUrlString(
                        'https://material.io/design/layout/responsive-layout-grid.html');
                  },
                  child: const Text('Material Design V2')),
            ),
            ResponsiveLayoutCell(
              position: const CellPosition.nextRow(),
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
