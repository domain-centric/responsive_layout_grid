[//]: # (This file was generated from: doc/template/README.mdt using the documentation_builder package on: 2022-06-20 21:01:14.403816.)
<a id='doc-template-badges-mdt'></a>[![Pub Package](https://img.shields.io/pub/v/responsive_layout_grid)](https://pub.dev/packages/responsive_layout_grid)
[![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/responsive_layout_grid)
[![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/responsive_layout_grid/wiki)
[![GitHub Stars](https://img.shields.io/github/stars/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/responsive_layout_grid/blob/main/LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/pulls)

<a id='doc-template-01-responsivelayoutgrid-mdt'></a><a id='responsivelayoutgrid'></a>
# ResponsiveLayoutGrid

Creates
a [Responsive Layout Grid as defined in the Material design guidelines](https://m3.material.io/foundations/adaptive-design/large-screens)

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid)
is made up of columns and gutters, providing a convenient layout structure for elements within the
body region.

As the width of the body region grows or shrinks, the number of grid columns and column widths
changes in response.

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid):

* Has a [minimumColumnWidth]
* Can have a [maxNumberOfColumns]
* Has a [columnGutterWidth]
* Has a [rowGutterWidth]
*
A [ResponsiveLayoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutfactory)
that determines the position of the cells.

All these can be set in
the [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid)
constructor.

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid)
has children, named cells.

* Cells align with the column grid to create a logical and consistent layout experience across
  screen sizes and orientations.
* Cells are [Widgets](https://docs.flutter.dev/development/ui/widgets-intro)
* Cells can span one or more columns
* Cells are separated with gutters (separation space)

It is recommended to wrap
a [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid)
in a:

* [Padding] widget to add outer margins
* [SingleChildScrollView] widget if the cells do not fit and vertical scrolling is needed.

<a id='responsivelayoutcell'></a>

# ResponsiveLayoutCell

You can wrap your cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)s
with
a [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutcell)
when you are using the [DefaultLayoutFactory], so that you can provide the following information of
the cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)
(the [child]):

* [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#cellposition)
  of the cell Widget.
* [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#columnspan)
  of the cell Widget.

<a id='cellposition'></a>

## CellPosition

A [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutcell)
has
a [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#cellposition)
. There are 2 types:

* nextColumn: The cell is to be positioned on the next available column. This could be on the next
  row if there aren't enough empty columns on the current row.
* nextRow: The cell is to be positioned on a new row. You can set
  the [CellAlignment](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#cellalignment)
  for every new row.

<a id='cellalignment'></a>

## CellAlignment

The [CellAlignment](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#cellalignment)
can be set when
a [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#cellposition).nextRow
is used in a
[ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutcell)
. It can be one of the following values:

* left: Align all cells on the left side of the row
* right: Align all cells on the right side of the row
* center: Try to align all cells in the middle of the row by increasing or decreasing
  the [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#columnspan)
  of one of the cells if needed.
* justify: Try to fill the row from left to right by increasing or decreasing
  the [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#columnspan)s
  of the cells if needed.

<a id='columnspan'></a>

## ColumnSpan

A [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#columnspan)
tells the [DefaultLayoutFactory] how many columns a
[ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutcell)
may span.

There is a [min], [preferred] and [max] value. The [DefaultLayoutFactory]
will try to use these values, but may also decide to use different values e.g.:

* When the number of available columns exceed [min] or [max]
* When the [CellAlignment.center] or [CellAlignment.justify] are used. In these cases it is good
  practice to have some distance between the
  [min], [preferred] and [max] values, so that the [DefaultLayoutFactory]
  has some flexibility to optimize the layout.


<a id='responsivelayoutfactory'></a>
# ResponsiveLayoutFactory

The [ResponsiveLayoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutfactory)
is responsible for creating a [Layout]. It orders the [children](https://pub.dev/packages/children)
into a Layout with a given number of columns.

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutgrid)
uses a [DefaultLayoutFactory] by default, but you could create your
own [ResponsiveLayoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/01-ResponsiveLayoutGrid#responsivelayoutfactory)
if you need to do something outside the box.

<a id='examples'></a>
# Examples
[See the live web demo including source code](http:%5C%5CTODO)