from .Line import Line
from datetime import datetime

from lib.Constants import USER_INPUT_SUFFIX


class LineStore():
    def __init__(self):
        self.__lines: list[Line] = []

    def getNewLines(self, lines: list[str]) -> list[Line]:
        "Returns new lines that are not already in the store"
        lines = self.__filterLines(lines)

        # get the last item in the list with a native timestamp
        lastNativeTimestamp = self.__getLastNativeTimestamp()

        # map raw lines to Line objects
        mappedLines = [Line(line) for line in lines]

        # find the last native timestamp in mappedLines that matches the last native timestamp in the store
        if lastNativeTimestamp is not None:
            lastMatchingMappedLineIndex: None | int = None
            for mappedLine in mappedLines:
                if mappedLine.nativeTimestamp == lastNativeTimestamp:
                    lastMatchingMappedLineIndex = mappedLines.index(
                        mappedLine)

            if lastMatchingMappedLineIndex is not None:
                # remove all lines before the last matching mapped line
                mappedLines = mappedLines[lastMatchingMappedLineIndex + 1:]

        # remove non-unique lines

        mappedLines = self.__filterUniqueLines(
            mappedLines, lastNativeTimestamp)

        self.__lines.extend(mappedLines)

        return mappedLines

    def __filterUniqueLines(self, lines: list[Line], lastNativeTimestamp: datetime | None) -> list[Line]:
        "Filters out lines that are already in the store"
        # remove lines that are already in the store after the last native timestamp
        uniqueLines: list[Line] = []
        lastNativeTimestampLine = next(
            (line for line in self.__lines if line.nativeTimestamp == lastNativeTimestamp), None)
        if lastNativeTimestampLine is not None:
            lastNativeTimestampLineIndex = self.__lines.index(
                lastNativeTimestampLine)
            for line in lines:
                # if the line.line is not in the line store, add it to the unique lines
                if line.line not in [l.line for l in self.__lines[lastNativeTimestampLineIndex + 1:]]:
                    uniqueLines.append(line)

            return uniqueLines
        else:
            # if there is no last native timestamp, return all lines
            return lines

    def __filterLines(self, lines: list[str]):
        "Filters out empty lines, single character lines, and lines that begin with >"
        # remove empty lines
        lines = [line for line in lines if line.strip() !=
                 '' or line.strip() != '>']

        # remove single character lines
        lines = [line for line in lines if len(line) > 1]

        # remove lines that begin with > BUT do not remove lines that begin with > and have a user input suffix
        lines = [line for line in lines if (not line.startswith(
            '>') or USER_INPUT_SUFFIX in line)]

        return lines

    def __getLastNativeTimestamp(self):
        "Returns the last native timestamp in the store"
        # get the last item in the list with a native timestamp
        lastNativeTimestamp: datetime | None = None
        for line in reversed(self.__lines):
            if line.nativeTimestamp is not None:
                lastNativeTimestamp = line.nativeTimestamp
                break
        return lastNativeTimestamp
