import 'dart:async';
import 'dart:math';
import '../classes/TimeTexts.dart';
import '../flutter_clock_helper/model.dart';

class GridBloc {
  /// This stream outputs a string, that is used to create the grid that
  /// tells the time and weather.
  /// Checks every second if the minute has changed, and if so, outputs the new
  /// string to the stream. If weather changes, it also outputs new string.
  /// The [Clock] widget listens to this stream, fills the empty spaces with letters
  /// and builds the grid.

  String _grid;
  ClockModel _model;

  final StreamController<String> _timeController = StreamController<String>();
  StreamSink<String> get _inGrid => _timeController.sink;
  Stream<String> get grid => _timeController.stream;

  GridBloc({ClockModel model}) {
    /// Takes the clockmodel as parameter and adds a listener
    /// so we can output new string to grid
    /// every time the weather updates.
    _model = model;
    _model.addListener(_refreshGrid);
    _initGrid();
    _startClock();
  }

  void _startClock() {
    /// Checks every second if minute has changed. If so,
    /// calls the method that updates the grid.

    /// We are only interested to see if the minute
    /// of [_oldTime] is different to the minute of
    /// [DateTime.now()], so we can put any values to
    /// the year and month etc...
    DateTime _oldTime = DateTime(2019, 1, 1, 1, DateTime.now().minute - 1);
    Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        DateTime now = DateTime.now();
        if (_oldTime.minute != now.minute) {
          _oldTime = now;
          _refreshGrid();
        }
      },
    );
  }

  void _refreshGrid() {
    /// Refreshes the grid with current time and weather.

    List<String> time = _getTimeAsText();
    _initGrid();
    _refreshTime(time: time);
    _refreshWeather();
    _inGrid.add(_grid);
  }

  List<String> _getTimeAsText() {
    /// Returns the current time as list of words.
    /// Eg. [{"It's", "five", "minutes", "past", "twelve"}]
    DateTime now = DateTime.now();
    int min = now.minute;
    int hour = now.hour;
    List<String> _time = List<String>();
    _time.add("it's");

    if (min != 0) {
      /// Takes the minutes from the correct index
      /// of a list of all the possible minutes.
      _time.add(TimeTexts.minutes[min]);
      if (min != 15 && min != 30 && min != 45) {
        if (min == 1 || min == 59) {
          _time.add("minute");
        } else {
          _time.add("minutes");
        }
      }
      if (min <= 30) {
        _time.add("past");
      } else {
        _time.add("to");
        hour++;
      }

      /// Takes the hours from the correct index
      /// of a list of all the possible hours
      _time.add(TimeTexts.hours[hour]);
    } else {
      /// Takes the hours from the correct index
      /// of a list of all the possible hours
      _time.add(TimeTexts.hours[hour]);
      if (now.hour != 0) {
        _time.add("o'clock");
      }
    }

    return _time;
  }

  void _refreshTime({List<String> time}) {
    /// Takes the time as list of strings as input.
    /// Input is eg. [{"It's", "five", "minutes", "past", "twelve"}].
    /// Then inserts every string in the input list on its own row
    /// in the [_grid] string. (the grid is 20x12, so each row
    /// is 20 characters long).

    Random r = Random();

    /// Specifies the rows in the grid in which the time will
    /// be displayed. All the remaining rows are used to display
    /// weather.
    final List<int> rows = [0, 2, 5, 8, 11];

    for (int i = 0; i < time.length; i++) {
      /// Current row
      int row = rows[i];

      /// Adds the string to the current row
      String str = time[i];
      int startIndex = (row * 20) + r.nextInt(20 - str.length);
      if (i == 0) {
        startIndex = 0;
      } else if (i == time.length - 1) {
        startIndex = _grid.length - str.length;
      }
      _grid = _grid.substring(0, startIndex) +
          str +
          _grid.substring(startIndex + str.length);
    }
  }

  void _refreshWeather() {
    /// Places every string from the [weather] list to its own
    /// row in the [_grid] string. [weather] list is generated
    /// by the data provided by [ClockModel] class.

    List<String> weather = [
      "weather",
      "is",
      "${_model.weatherString}",
      "and",
      "it's",
      "${_model.temperature.round()}${_model.unitString}",
      "outside",
    ];
    Random r = Random();

    /// Specifies the rows in the grid in which the weather will
    /// be displayed. All the remaining rows are used to display
    /// time.
    final List<int> rows = [1, 3, 4, 6, 7, 9, 10];

    for (int i = 0; i < weather.length; i++) {
      /// Current row
      int row = rows[i];

      /// Adds the weather string to the current [row]
      String str = weather[i];
      int startIndex = (row * 20) + r.nextInt(20 - str.length);
      _grid = _grid.substring(0, startIndex) +
          str +
          _grid.substring(startIndex + str.length);
    }
  }

  void _initGrid() {
    /// Initializes the grid by filling the [_grid] string
    /// with spaces
    _grid = " " * 240;
  }

  void dispose() {
    /// This is called to close the stream and listener,
    /// in order to prevent memory leaks.
    _timeController.close();
    _model.removeListener(_refreshWeather);
  }
}
