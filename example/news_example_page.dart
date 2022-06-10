import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

import 'random.dart';

class NewsLayoutExamplePage extends StatelessWidget {
  const NewsLayoutExamplePage({Key? key}) : super(key: key);
  static const double gutterSize = 32;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Sport Camp Registration Form (resize me!)'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: ResponsiveLayoutGrid(
              maxNumberOfColumns: 8,
              columnGutterWidth: gutterSize,
              rowGutterHeight: gutterSize,
              cells: [
                ResponsiveLayoutCell(
                    columnSpan: ColumnSpan.remainingWidth(),
                    child: Center(
                      child: Text(
                        randomLoremIpsumTitle(),
                        style: const TextStyle(fontSize: 30),
                      ),
                    )),
                for (int i = 0; i < 20; i++) createArticle(),
              ],
            )),
      ));

  ResponsiveLayoutCell createArticle() {
    var size = randomInt(min: 1, max: 3);
    return ResponsiveLayoutCell(
      columnSpan: ColumnSpan.range(size, size),
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  randomLoremIpsumTitle(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            Text(
                randomLoremIpsumChapter(
                    minParagraphs: size,
                    maxParagraphs: size,
                    minSentencesPerParagraph: 5,
                    maxSentencesPerParagraph: 6),
                textAlign: TextAlign.justify),
          ],
        ),
      ),
    );
  }
}
