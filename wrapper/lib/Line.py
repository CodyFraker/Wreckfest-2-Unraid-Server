from datetime import datetime

from lib.Constants import USER_INPUT_SUFFIX, USER_INPUT_TIMESTAMP_FORMAT


class Line():
    "Class to represent a line with a timestamp"

    def __init__(self, line: str):
        "Initializes the line with the current timestamp"
        self.isUserTimestampLine = self.__isUserInputLine(line)
        self.nativeTimestamp = self.__getNativeTimestamp(line)

        if (self.isUserTimestampLine):
            self.line = line.split(USER_INPUT_SUFFIX)[0]
        else:
            self.line = line.rstrip()

        if self.nativeTimestamp is not None:
            # set the timestamp to today with the time from the line
            self.timestamp = datetime.combine(
                datetime.today(), self.nativeTimestamp.time())
        else:
            # set the timestamp to now
            self.timestamp = datetime.now()

    def __str__(self):
        "Returns the string representation of the line with timestamp"
        return f'{self.timestamp.strftime(USER_INPUT_TIMESTAMP_FORMAT)} {self.line}'

    def isEqualTo(self, line: 'Line'):
        "Checks if the line is equal to another line based on content *and day of timestamp*"
        return self.line == line.line and self.timestamp.date() == line.timestamp.date()

    def __isUserInputLine(self, line: str):
        "Checks if the line is a user input line"
        return USER_INPUT_SUFFIX in line

    def __getNativeTimestamp(self, line: str):
        "Parses the line to extract the timestamp"
        # timestamp is in format hh:mm:ss.### - we can ignore the milliseconds, should return the time with today's date
        # split the line into time and message
        if (self.isUserTimestampLine):
            # if the line is a user input line, we need to check for the timestamp after the user input suffix
            # cut off any text after the timestamp
            afterSuffix = line.split(USER_INPUT_SUFFIX)[1]
            # only take the first 19 characters of the timestamp
            timestamp = afterSuffix[:19]

            return datetime.strptime(timestamp, USER_INPUT_TIMESTAMP_FORMAT)

        timeString = line.split('.')[0]

        if (timeString == ''):
            return None
        # create a datetime object with the time and today's date
        # try to parse the time string

        try:
            # return datetime with today's date and the time from the string
            nativeDateTime = datetime.strptime(timeString, "%H:%M:%S")
            # set the date to today
            nativeDateTime = nativeDateTime.replace(
                year=datetime.today().year, month=datetime.today().month, day=datetime.today().day)
            return nativeDateTime

        except ValueError:
            # if the time string is not in the correct format, return None
            return None
