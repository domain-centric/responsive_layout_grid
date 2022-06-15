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
        body: const SingleChildScrollView(
          child:
              Padding(padding: EdgeInsets.all(8), child: ResponsiveFormGrid()),
        ),
      );
}

class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveLayoutGrid(
        maxNumberOfColumns: maxNumberOfColumns,
    children: [
          _createGroupBar('Participant'),
          _createTextField(
            label: 'Given name',
            position: const CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Family name',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Date of birth',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
              label: 'Remarks (e.g. medicines and allergies)',
              position: const CellPosition.nextRow(),
              columnSpan: const ColumnSpan.size(3),
              maxLines: 5),
          _createGroupBar('Home Address'),
          _createTextField(
              label: 'Street',
              position: const CellPosition.nextRow(),
              maxLines: 2),
          _createTextField(
            label: 'City',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Region',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Postal code',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Country',
            position: const CellPosition.nextColumn(),
          ),
          _createGroupBar('Consent'),
          _createTextField(
            label: 'Given name of parent or guardian',
            position: const CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Family name of parent or guardian',
            position: const CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Phone number of parent or guardian',
            position: const CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Second phone number in case of emergency',
            position: const CellPosition.nextColumn(),
          ),
          _createButtonBarGutter(),
          _createSubmitButton(
              context, const CellPosition.nextRow(CellAlignment.right)),
          _createCancelButton(context, const CellPosition.nextColumn()),
        ],
      );

  ResponsiveLayoutCell _createGroupBar(String title) => ResponsiveLayoutCell(
        position: const CellPosition.nextRow(),
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

  ResponsiveLayoutCell _createTextField({
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
          decoration: InputDecoration(
              label: Text(label),
              filled: true,
              border: const OutlineInputBorder()),
        ),
      );

  ResponsiveLayoutCell _createSubmitButton(
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

  ResponsiveLayoutCell _createCancelButton(
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

  _createButtonBarGutter() => const ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: SizedBox(height: 8),
      );
}
