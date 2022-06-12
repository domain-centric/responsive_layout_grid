import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

const maxNumberOfColumns = 8;

class FormLayoutExamplePage extends StatelessWidget {
  const FormLayoutExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sport Camp Registration Form (resize me!)'),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: const [
                  ResponsiveFieldGrid(),
                  SizedBox(height: 24),
                  ResponsiveButtonGrid(),
                ],
              )),
        ),
      );
}

class ResponsiveFieldGrid extends StatelessWidget {
  const ResponsiveFieldGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveLayoutGrid(
        maxNumberOfColumns: maxNumberOfColumns,
        cells: [
          createGroupBar('Participant'),
          createTextField(
            label: 'Given name',
            position: CellPosition.nextRow,
          ),
          createTextField(
            label: 'Family name',
            position: CellPosition.nextColumn,
          ),
          createTextField(
            label: 'Date of birth',
            position: CellPosition.nextColumn,
          ),
          createTextField(
              label: 'Remarks (e.g. medicines and allergies)',
              position: CellPosition.nextRow,
              columnSpan: const ColumnSpan.size(3),
              maxLines: 5),
          createGroupBar('Home Address'),
          createTextField(
              label: 'Street', position: CellPosition.nextRow, maxLines: 2),
          createTextField(
            label: 'City',
            position: CellPosition.nextColumn,
          ),
          createTextField(
            label: 'Region',
            position: CellPosition.nextColumn,
          ),
          createTextField(
            label: 'Postal code',
            position: CellPosition.nextColumn,
          ),
          createTextField(
            label: 'Country',
            position: CellPosition.nextColumn,
          ),
          createGroupBar('Consent'),
          createTextField(
            label: 'Given name of parent or guardian',
            position: CellPosition.nextRow,
          ),
          createTextField(
            label: 'Family name of parent or guardian',
            position: CellPosition.nextColumn,
          ),
          createTextField(
            label: 'Phone number of parent or guardian',
            position: CellPosition.nextRow,
          ),
          createTextField(
            label: 'Second phone number in case of emergency',
            position: CellPosition.nextColumn,
          ),
        ],
      );

  ResponsiveLayoutCell createGroupBar(String title) => ResponsiveLayoutCell(
        position: CellPosition.nextRow,
        columnSpan: ColumnSpan.remainingWidth(),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey,
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );

  /// TODO remove later
  /// Used with gray background
  ResponsiveLayoutCell createTextFieldNilsStyle({
    required String label,
    required CellPosition position,
    ColumnSpan columnSpan = const ColumnSpan.size(2),
    int maxLines = 1,
  }) =>
      ResponsiveLayoutCell(
        position: position,
        columnSpan: columnSpan,
        child: Column(children: [
          Align(alignment: Alignment.topLeft, child: Text(label)),
          TextFormField(
            maxLines: maxLines,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
            ),
          ),
        ]),
      );


  ResponsiveLayoutCell createTextField({
    required String label,
    required CellPosition position,
    ColumnSpan columnSpan = const ColumnSpan.size(2),
    int maxLines = 1,
  }) =>
      ResponsiveLayoutCell(
        position: position,
        columnSpan: columnSpan,
        child: TextFormField(
            maxLines: maxLines,
            decoration:  InputDecoration(
              label: Text(label),
              filled: true,
              border: const OutlineInputBorder()
            ),
          ),
        );
}

class ResponsiveButtonGrid extends StatelessWidget {
  const ResponsiveButtonGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveLayoutGrid(
        maxNumberOfColumns: maxNumberOfColumns,
        layoutFactory: const DefaultLayoutFactory(
          cellAlignment: CellAlignment.right,
        ),
        cells: [
          createSubmitButton(context, CellPosition.nextRow),
          createCancelButton(context, CellPosition.nextColumn),
        ],
      );

  ResponsiveLayoutCell createSubmitButton(
      BuildContext context, CellPosition position) {
    return ResponsiveLayoutCell(
        position: position,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child:
              const Padding(padding: EdgeInsets.all(16), child: Text('Submit')),
        ));
  }

  ResponsiveLayoutCell createCancelButton(
      BuildContext context, CellPosition position) {
    return ResponsiveLayoutCell(
        position: position,
        child: OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child:
              const Padding(padding: EdgeInsets.all(16), child: Text('Cancel')),
        ));
  }
}
