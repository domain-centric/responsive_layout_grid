import 'package:flutter/material.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

class FormExamplePage extends StatelessWidget {
  const FormExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Sport Camp Registration Form (resize me!)'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[300],
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: ResponsiveLayoutGrid(
                maxNumberOfColumns: 8,
                cells: [
                  createGroupBar('Participant'),
                  createTextField(
                    label: 'Given name',
                    position: CellPosition.nextRowLeftToRight,
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
                      position: CellPosition.nextRowLeftToRight,
                      columnSpan: const ColumnSpan.size(3),
                      maxLines: 5),
                  createGroupBar('Home Address'),
                  createTextField(
                      label: 'Street',
                      position: CellPosition.nextRowLeftToRight,
                      maxLines: 2),
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
                    position: CellPosition.nextRowLeftToRight,
                  ),
                  createTextField(
                    label: 'Family name of parent or guardian',
                    position: CellPosition.nextColumn,
                  ),
                  createTextField(
                    label: 'Phone number of parent or guardian',
                    position: CellPosition.nextRowLeftToRight,
                  ),
                  createTextField(
                    label: 'Second phone number in case of emergency',
                    position: CellPosition.nextColumn,
                  ),
                  buttonGutter(),
                  createSubmitButton(context, CellPosition.nextRowRightToLeft),
                  createCancelButton(context, CellPosition.nextColumn),
                ],
              )),
        ),
      ));

  ResponsiveLayoutCell buttonGutter() => const ResponsiveLayoutCell(
        position: CellPosition.nextRowLeftToRight,
        child: SizedBox(
          height: 8,
        ),
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

  ResponsiveLayoutCell createGroupBar(String title) => ResponsiveLayoutCell(
        position: CellPosition.nextRowLeftToRight,
        columnSpan: ColumnSpan.remainingWidth(),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey,
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );

  ResponsiveLayoutCell createGroupBar2(String title) => ResponsiveLayoutCell(
        position: CellPosition.nextRowLeftToRight,
        columnSpan: ColumnSpan.remainingWidth(),
        child: Text(title,
            style: const TextStyle(color: Colors.blue, fontSize: 18)),
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
}
