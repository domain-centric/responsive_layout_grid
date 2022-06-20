/*
 * Copyright (c) 2022. By Nils ten Hoeve. See LICENSE file in project.
 */

import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/src/responsive_layout_grid.dart';

import 'random.dart';
import 'scroll_view_with_scroll_bar.dart';

class NewsPaperExamplePage extends StatelessWidget {
  const NewsPaperExamplePage({Key? key}) : super(key: key);
  static const title = 'News Paper';

  //TODO update to correct demo project and source code file;
  static const urlToSourceCode='https://github.com/domain-centric/responsive_layout_grid';
  static const double gutterSize = 32;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('$title Example (resize me!)'),
      ),
      body: ScrollViewWithScrollBar(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: ResponsiveLayoutGrid(
              maxNumberOfColumns: 8,
              columnGutterWidth: gutterSize,
              rowGutterHeight: gutterSize,
              children: [
                _createBigTitle(),
                for (int i = 0; i < 20; i++) _createArticle(),
              ],
            )),
      ));

  ResponsiveLayoutCell _createBigTitle() => ResponsiveLayoutCell(
      columnSpan: ColumnSpan.remainingWidth(),
      position: const CellPosition.nextRow(CellAlignment.justify),
      child: Center(
        child: Text(
          randomLoremIpsumTitle(),
          style: const TextStyle(fontSize: 30),
        ),
      ));

  ResponsiveLayoutCell _createArticle() {
    var min=1;
    var preferred=min+randomInt(min: 0, max: 3);
    var max= preferred+randomInt(min: 0, max: 3);
    return ResponsiveLayoutCell(
      columnSpan: ColumnSpan.range(min: min, preferred: preferred, max: max),
      child: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            _createArticleTitle(),
            _createArticleText(preferred),
          ],
        ),
      ),
    );
  }

  Text _createArticleText(int preferred) {
    return Text(
        randomLoremIpsumChapter(
            minParagraphs: preferred,
            maxParagraphs: preferred,
            minSentencesPerParagraph: 5,
            maxSentencesPerParagraph: 6),
        textAlign: TextAlign.justify);
  }

  Padding _createArticleTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          randomLoremIpsumTitle(),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
