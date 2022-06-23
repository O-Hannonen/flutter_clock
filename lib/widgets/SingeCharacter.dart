import 'package:flutter/material.dart';
import 'dart:async';

class SingleCharacter extends StatelessWidget {
  /// The character to be displayed in this widget
  final String text;

  /// Is the character a part of a string that
  /// tells the weather.
  final bool isWeather;

  /// Is the character a part of a string that
  /// tells the time.
  final bool isTime;

  /// Factor of the delay between changing color to highlighted after initialization.
  /// This factor is smallest to the characters at top left corner and highest
  /// to the characters at bottom right corner. For characters that does not display
  /// time or weather (background characters) this factor is set to 0. This creates
  /// a sweeping animation when time or weather is updated.
  final int animationDelay;

  /// Context is used to access information of the current theme.
  final BuildContext context;

  SingleCharacter({
    Key key,
    this.text,
    this.animationDelay,
    this.context,
    this.isWeather,
    this.isTime,
  }) : super(key: key);

  Stream<Color> getColor() async* {
    if (Theme.of(context).brightness == Brightness.dark) {
      yield Colors.grey[900];
    } else {
      yield Colors.grey[300];
    }
    await Future.delayed(Duration(milliseconds: 50 * animationDelay));
    if (isTime) {
      if (Theme.of(context).brightness == Brightness.dark) {
        yield Colors.yellow[50];
      } else {
        yield Colors.black;
      }
    } else if (isWeather) {
      yield Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Uses streambuilder so that the stateless widget rebuilds 
    /// when color is updated (50ms*[animationTime] waited)
    return Center(
      child: StreamBuilder<Color>(
        stream: getColor(),
        builder: (context, snapshot) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              text.toUpperCase(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: snapshot.data,
                fontSize: 15.0,
                fontFamily: 'Cardo',
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
