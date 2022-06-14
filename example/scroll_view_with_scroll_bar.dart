import 'package:flutter/material.dart';

/// It looks like ScrollBars with Material design are often not present
/// (see listview) and if they are included, they are hidden when the user does
/// not scroll.
///
/// The negative side effect of this decision is that the user does not see
/// that the user interface extends the viewport. E.g. it is possible that the
/// user does not see all fields in a form or does not see that he needs to scroll
/// down to see a cancel or submit button.
///
/// This is why the (windows)
///
/// [ScrollViewWithScrollBar] therefore shows the scroll bar if its child does
/// not fit inside the [ScrollViewWithScrollBar]
///
/// Based on [this example](https://stackoverflow.com/questions/54963284/always-show-scrollbar-flutter)

class ScrollViewWithScrollBar extends StatefulWidget {
  final Widget child;

  const ScrollViewWithScrollBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScrollViewWithScrollBar> createState() =>
      _ScrollViewWithScrollBarState();
}

class _ScrollViewWithScrollBarState extends State<ScrollViewWithScrollBar> {
  final _scrollController = ScrollController();
  bool _hasHorizontalScrollBar = false;
  bool _hasVerticalScrollBar = false;

  @override
  Widget build(BuildContext context) {
    return
      RawScrollbar(
        thumbColor: Colors.grey,
        thickness: 8,
        radius: const Radius.circular(8),
        controller: _scrollController,
        thumbVisibility: true,
        notificationPredicate: scrollNotificationPredicate,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, _hasVerticalScrollBar ? 8 : 0,
                _hasHorizontalScrollBar ? 8 : 0),
            child: widget.child,
          ),
        ));
  }

  /// A [ScrollNotificationPredicate] that checks whether
  /// `notification.depth == 0`, which means that the notification did not bubble
  /// through any intervening scrolling widgets.
  bool scrollNotificationPredicate(ScrollNotification notification) {
    if (notification.depth == 0) {
      setState(() {
        var metrics = notification.metrics;
        _hasHorizontalScrollBar =
            metrics.axis == Axis.horizontal && metrics.maxScrollExtent > 0;
        _hasVerticalScrollBar =
            metrics.axis == Axis.vertical && metrics.maxScrollExtent > 0;
      });
    }
    return notification.depth == 0;
  }
}


