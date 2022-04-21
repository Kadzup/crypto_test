DateTime parseDateTime(String value) {
  DateTime dateTime = DateTime.now();

  String datePart = value.split("T").first;
  var dateList = datePart.split("-");
  String timePart = value.split("T").last.replaceAll("Z", "");
  var timeList = timePart.split(":");

  dateTime = DateTime(
    // date
    int.parse(dateList[0]),
    int.parse(dateList[1]),
    int.parse(dateList[2]),
    // time
    int.parse(timeList[0]),
    int.parse(timeList[1]),
    int.parse(timeList[2].replaceRange(
      timeList[2].indexOf("."),
      timeList[2].length - 1,
      "",
    )),
  );

  return dateTime;
}
