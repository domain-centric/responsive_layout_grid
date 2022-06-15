import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'column_example_page.dart';
import 'form2_example_page.dart';
import 'form_example_page.dart';
import 'news_example_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('$ResponsiveLayoutGrid (resize me!)'),
      ),
      body: const SingleChildScrollView(
        child:
            Padding(padding: EdgeInsets.all(32), child: ResponsiveHomeGrid()),
      ));
}

class ResponsiveHomeGrid extends StatelessWidget {
  const ResponsiveHomeGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ResponsiveLayoutGrid(maxNumberOfColumns: 4, children: [
        _createGroupBar("Examples"),
        _createButton(
          title: 'Columns Layout',
          onClick: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ColumnLayoutExamplePage()));
          },
        ),
        _createButton(
          title: 'Form Layout',
          onClick: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FormLayoutExamplePage()));
          },
        ),
        _createButton(
          title: 'Form2Layout',
          onClick: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Form2LayoutExamplePage()));
          },
        ),
        _createButton(
          title: 'NewsLayout',
          onClick: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewsLayoutExamplePage()));
          },
        ),
        _createGroupBar("Documentation"),
        _createButton(
          title: 'Material Design V2',
          onClick: () {
            launchUrlString(
                'https://material.io/design/layout/responsive-layout-grid.html');
          },
        ),
        _createButton(
          title: 'Material Design V3',
          onClick: () {
            launchUrlString(
                'https://m3.material.io/foundations/adaptive-design/large-screens/overview');
          },
        ),
      ]);

  ResponsiveLayoutCell _createButton({
    required String title,
    required Function() onClick,
  }) {
    return ResponsiveLayoutCell(
      position: const CellPosition.nextRow(),
      child: OutlinedButton(
          onPressed: () {
            onClick();
          },
          child: Text(title)),
    );
  }

  ResponsiveLayoutCell _createGroupBar(String title) {
    return ResponsiveLayoutCell(
      position: const CellPosition.nextRow(),
      columnSpan: ColumnSpan.remainingWidth(),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
