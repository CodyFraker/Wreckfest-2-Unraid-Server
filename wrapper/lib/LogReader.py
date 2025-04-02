import os
import time


class LogReader():
    "Class to read the log file and return a generator of lines"

    def __init__(self, filename: str):
        self.__filename = filename

        # check if file exists, if not create it
        if not os.path.exists(self.__filename):
            with open(self.__filename, 'w'):
                pass

        self.__file = open(self.__filename, 'r')
        self.__file.seek(0, os.SEEK_END)

    def tail(self):
        "Returns a generator that yields lines from the file"
        while True:
            line = self.__file.readline()
            if not line:
                time.sleep(0.1)
                continue
            yield line
