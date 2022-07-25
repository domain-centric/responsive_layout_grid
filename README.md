[//]: # (This file was generated from: doc/template/README.mdt using the documentation_builder package on: 2022-07-25 20:21:31.096552.)
<a id='doc-template-badges-mdt'></a>[![Pub Package](https://img.shields.io/pub/v/responsive_layout_grid)](https://pub.dev/packages/responsive_layout_grid)
[![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/responsive_layout_grid)
[![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/responsive_layout_grid/wiki)
[![GitHub Stars](https://img.shields.io/github/stars/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/responsive_layout_grid/blob/main/LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/domain-centric/responsive_layout_grid)](https://github.com/domain-centric/responsive_layout_grid/pulls)

<a id='introduction'></a>

# Introduction

The [ResponsiveLayoutGrid] creates
a [Responsive Layout Grid as defined in the Material design guidelines](https://m3.material.io/foundations/adaptive-design/large-screens)

![](https://github.com/domain-centric/responsive_layout_grid/wiki/columns.gif)

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
is made up of columns and gutters, providing a convenient layout structure for elements within the
body region.

As the width of the body region grows or shrinks, the number of grid columns and column widths
change in response.

![](https://github.com/domain-centric/responsive_layout_grid/wiki/form.gif)

<a id='examples'></a>

# Examples

[See the live web demo including source code](https://domain-centric.github.io/responsive_layout_grid_demo_web)

<a id='doc-template-02-responsivelayoutgrid-mdt'></a><a id='responsivelayoutgrid'></a>

# ResponsiveLayoutGrid

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
has the following constructor parameters:

* [minimumColumnWidth]
* [maxNumberOfColumns]
* [columnGutterWidth]
* [rowGutterHeight]
* [padding]
* [children](https://pub.dev/packages/children) (the cells)
* [layoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutfactory) (
  that determines the position of the cells)

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
has children, named cells.

* Cells align with the column grid to create a logical and consistent layout experience across
  screen sizes and orientations:
  *
  The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
  sets de width of the cells.
  * The cells can determine their own height, unless
    the [RowHeight](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#rowheight)
    is set.
* Cells are [Widgets](https://docs.flutter.dev/development/ui/widgets-intro)
* Cells can span one or more columns
* Cells are separated with gutters (separation space)

It is recommended to always directly wrap
a [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
in a
[SingleChildScrollView] so that the user can vertically scroll trough all cells, even when they do
not all fit in the viewport.

<a id='responsivelayoutcell'></a>

# ResponsiveLayoutCell

You can wrap your cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)s
with
a [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
when you are using the [DefaultLayoutFactory], so that you can provide the following information of
the cell [Widget](https://docs.flutter.dev/development/ui/widgets-intro)
(the [child]):

* [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#columnspan)
  of the cell Widget.
* [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#cellposition)
  of the cell Widget.


<a id='columnspan'></a>
## ColumnSpan

A [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#columnspan)
tells the [DefaultLayoutFactory] how many columns a
[ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
may span.

There is a [min], [preferred] and [max] value. The [DefaultLayoutFactory]
will try to use these values, but may also decide to use different values e.g.:

* When the number of available columns exceed [min] or [max]
* When the [RowAlignment.center] or [RowAlignment.justify] are used. In these cases it is good
  practice to have some distance between the
  [min], [preferred] and [max] values, so that the [DefaultLayoutFactory]
  has some flexibility to optimize the layout.

<a id='cellposition'></a>

## CellPosition

A [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
has
a [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#cellposition)
. There are 2 types:

* nextColumn: The cell is to be positioned on the next available column. This could be on the next
  row if there aren't enough empty columns on the current row.
* nextRow: The cell is to be positioned on a new row. You can set
  the [RowAlignment](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#rowalignment)
  or [RowHeight](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#rowheight)
  for every new row.

<a id='rowalignment'></a>

## RowAlignment

The [RowAlignment](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#rowalignment)
can be set when
a [CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#cellposition).nextRow
is used in a
[ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
. It can be one of the following values:

* left: Align all cells on the left side of the row
* right: Align all cells on the right side of the row
* center: Try to align all cells in the middle of the row by increasing or decreasing
  the [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#columnspan)
  of one of the cells if needed.
* justify: Try to fill the row from left to right by increasing or decreasing
  the [ColumnSpan](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#columnspan)s
  of the cells if needed.

<a id='rowheight'></a>

## RowHeight

The [RowHeight](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#rowheight)
is used as a parameter in
[CellPosition](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#cellposition).nextRow
. It defines the height the following row.

There are 2 types of row heights:

* highestCell: The row will get the height of the highest
  [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
* expanded: The row will get the remaining available height. If multiple rows are expanded, the
  available space is divided among them according to the [minHeight], but also respecting
  [maxHeight].

Both types can have a [minHeight] and a [maxHeight]

The [minHeight] of
the [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell):

* null= no minimum
  height ([ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
  can shrink to zero)
* &gt;0
  = [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
  minimum size. Note that the [RenderResponsiveLayout] children now can take up more space than
  available. It is therefore recommended to wrap the [RenderResponsiveLayout] inside
  a [SingleChildScrollView] or other scrollview

The [maxHeight] of
the [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell):

* null= no maximum
  height ([ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
  can shrink to zero)
* &gt;0
  = [ResponsiveLayoutCell](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutcell)
  maximum size.

<a id='responsivelayoutfactory'></a>

# ResponsiveLayoutFactory

The [ResponsiveLayoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutfactory)
is responsible for creating a [Layout]. It orders the [children](https://pub.dev/packages/children)
into a Layout with a given number of columns.

The [ResponsiveLayoutGrid](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutgrid)
uses a [DefaultLayoutFactory] by default.

You could create your
own [ResponsiveLayoutFactory](https://github.com/domain-centric/responsive_layout_grid/wiki/02-ResponsiveLayoutGrid#responsivelayoutfactory)
if you need to do something outside the box.
See [example](https://github.com/domain-centric/responsive_layout_grid_demo/blob/main/lib/column_example.dart)
.


