/*
 * Copyright (c) 2022. By Nils ten Hoeve. See LICENSE file in project.
 */

import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/src/responsive_layout_grid.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'alignment_example_page.dart';
import 'columns_example_page.dart';
import 'form2_example_page.dart';
import 'form_example_page.dart';
import 'news_paper_example_page.dart';

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
  Widget build(BuildContext context) => ResponsiveLayoutGrid(
    maxNumberOfColumns: 2,
    children: [
      ResponsiveLayoutCell(
        position: const CellPosition.nextRow(),
        columnSpan: ColumnSpan.remainingWidth(),
        child: const GroupBar("Examples"),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: NavigateToPageButton(
          text: ColumnsExamplePage.title,
          page: ColumnsExamplePage(),
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextColumn(),
        child: OpenUrlButton(
          text: '${ColumnsExamplePage.title} Source Code',
          url: FormExamplePage.urlToSourceCode,
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: NavigateToPageButton(
          text: FormExamplePage.title,
          page: FormExamplePage(),
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextColumn(),
        child: OpenUrlButton(
          text: '${FormExamplePage.title} Source Code',
          url: FormExamplePage.urlToSourceCode,
        ),
      ),
      ResponsiveLayoutCell(
        //TODO move to other project
        position: const CellPosition.nextRow(),
        child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const Form2LayoutExamplePage()));
            },
            child: const Text('Form2 Layout')),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: NavigateToPageButton(
          text: NewsPaperExamplePage.title,
          page: NewsPaperExamplePage(),
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextColumn(),
        child: OpenUrlButton(
          text: '${NewsPaperExamplePage.title} Source Code',
          url: NewsPaperExamplePage.urlToSourceCode,
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: NavigateToPageButton(
          text: AlignmentExamplePage.title,
          page: AlignmentExamplePage(),
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextColumn(),
        child: OpenUrlButton(
          text: '${AlignmentExamplePage.title} Source Code',
          url: AlignmentExamplePage.urlToSourceCode,
        ),
      ),
      ResponsiveLayoutCell(
        position: const CellPosition.nextRow(),
        columnSpan: ColumnSpan.remainingWidth(),
        child: const GroupBar("Documentation"),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: OpenUrlButton(
          text: 'Material Design V2',
          url:
          'https://material.io/design/layout/responsive-layout-grid.html',
        ),
      ),
      const ResponsiveLayoutCell(
        position: CellPosition.nextColumn(),
        child: OpenUrlButton(
          text: 'Material Design V3',
          url:
          'https://m3.material.io/foundations/adaptive-design/large-screens/overview',
        ),
      ),
    ],
  );
}

class OpenUrlButton extends StatelessWidget {
  final String text;
  final String url;

  const OpenUrlButton({
    Key? key,
    required this.text,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => OutlinedButton(
      onPressed: () {
        launchUrlString(url);
      },
      child: ButtonText(text));
}

class NavigateToPageButton extends StatelessWidget {
  final String text;
  final Widget page;

  const NavigateToPageButton({
    Key? key,
    required this.text,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => OutlinedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: ButtonText(text));
}

class ButtonText extends StatelessWidget {
  final String text;

  const ButtonText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0,16,0,16),
    child: Text(text),
  );
}

class GroupBar extends StatelessWidget {
  final String title;

  const GroupBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey,
      child: Center(
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ));
}
