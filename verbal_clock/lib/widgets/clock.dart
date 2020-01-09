import 'dart:async';
import 'package:flutter/material.dart';
import '../bloc/GridBloc.dart';
import '../flutter_clock_helper/model.dart';
import 'SingeCharacter.dart';

class Clock extends StatefulWidget {
  final ClockModel model;
  Clock({Key key, this.model}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  /// This is the base widget of this clockface.
  /// It builds a 20x12 grid of [SingleCharacter]s.
  /// This subscribes to [GridBloc]s [grid] stream which outputs a string
  /// which contains the time and weather as text.
  /// The string is used to build the grid. The string is
  /// 20x12=240 characters long. The first 20 characters are
  /// the ones that are used to build the first row in the grid.
  /// The next 20 characters are used to build the second row in
  /// the grid and so on. If the character is just a whitespace,
  /// it picks character in corresponding index from [emptyGrid].
  /// Those characters are displayed the so called background characters,
  /// that does not tell time or weather. If the character is not a whitespace, it
  /// displays time or weather, and is colored according to that.

  GridBloc _gridBloc;
  final String emptyGrid =
      "fivequartersevenfivemidnightfourteenfivetwentysevenafternoonpastfiftythreefourtyhalftenmidnightonetofivequartersevenfivemidnightfourteenfivetwentysevenafternoonpastfiftythreefourtyfivequartersevenfivemidnightfourteenfivetwentysevenafternoon";

  @override
  void initState() {
    /// Passes the ClockModel to the bloc
    _gridBloc = GridBloc(model: widget.model);
    super.initState();
  }

  @override
  void dispose() {
    /// Closes all the streams in the bloc
    _gridBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.yellow[50],
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: EdgeInsets.all(3.0),
          child: StreamBuilder<String>(
            stream: _gridBloc.grid,
            initialData: " " * 240,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 20,
                childAspectRatio: 1,
                children: buildGrid(grid: snapshot.data),
              );
            },
          ),
        ),
      ),
    );
  }

  List<SingleCharacter> buildGrid({String grid}) {
    /// Every time when minute or weather changes, this is called.
    /// Creates a list of SingleCharacters to be displayed
    /// at the grid.

    /// [weatherRows] are the rows in the grid that are used to
    /// display weather. First 20 characters of [grid]
    /// string are used to build the first row of the grid.
    /// The next 20 characters are used to build the second
    /// row in the grid, and so on. We can check if the index
    /// of the current character is in the range of indexes that
    /// are used to build the rows that display weather. Thats how
    /// we can tell apart characters that display time and characters
    /// that display weather.
    List<int> weatherRows = [1, 3, 4, 6, 7, 9, 10];

    /// These delays creates the sweeping animation
    /// when the widget is rebuild.
    int timeAnimationDelay = 0;
    int weatherAnimationDelay = 0;

    List<SingleCharacter> output = List.generate(
      grid.length,
      (int index) {
        String chr = grid[index];
        bool isWeather = false;
        bool isTime = false;
        if (chr == " ") {
          /// if the character at this specific index is empty,
          /// that means we want to fill it with some random background
          /// letters from [emptyGrid].
          chr = emptyGrid[index];
        } else {
          /// Counts the row in which this character will be displayed.
          int row = (index / 20).floor();

          /// Checks if [row] is a row that is used to display weather.
          /// By changing these booleans according to that, we can apply
          /// different colors to weather text and time text, so its possible
          /// to tell them apart. This also increases the delays, which
          /// makes the sweeping animations
          if (weatherRows.contains(row)) {
            isWeather = true;
            weatherAnimationDelay += 1;
          } else {
            isTime = true;
            timeAnimationDelay += 1;
          }
        }

        return SingleCharacter(
          text: chr,
          isWeather: isWeather,
          isTime: isTime,
          animationDelay: isWeather
              ? weatherAnimationDelay
              : isTime ? timeAnimationDelay : 0,
          context: context,
        );
      },
    );

    return output;
  }
}
