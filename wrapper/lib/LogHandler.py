from typing import Generator
from threading import Thread


class LogHandler():
    "Class to print the lines from a generator"

    def __init__(self, generator: Generator[str, None, None]):
        self.__generator = generator

    def startPrint(self):
        self.__loopThread = Thread(target=self.__loop)
        self.__loopThread.start()

    def __loop(self):
        while True:
            line = next(self.__generator)
            if line.strip() == '':
                continue
            # remove trailing whitespace
            line = line.rstrip()
            print(line)
