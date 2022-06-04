import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

import 'column_example_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '$ResponsiveLayoutGrid',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ColumnExamplePage());
  }
}

