import subprocess
from threading import Thread
import time
import os

from lib.ConsoleWriter import ConsoleWriter
from lib.LogWriter import LogWriter
from lib.LogReader import LogReader
from lib.LogHandler import LogHandler


class Main():
    "Main class to run the program"

    def __init__(self):
        self.__logFilePath = os.environ['WFLOGFILEDIR'] + '/server.log'
        self.__logReader = LogReader(self.__logFilePath)
        self.__consoleWriter = ConsoleWriter()

        self.__logHandler = LogHandler(self.__logReader.tail())

        self.__logWriter = LogWriter(self.__logFilePath)

    def start(self):
        self.__logHandler.startPrint()
        self.__logWriter.start()

        time.sleep(5)

        self.__logWriter.stop()

        # send enter 30 times
        for _i in range(30):
            subprocess.run(['xdotool', "key", "Return"])
            time.sleep(0.1)

        self.__logWriter.start()

        self.__consoleWriter.start()

        Thread(target=self.__conflictHandler).start()

    def __conflictHandler(self):
        "Handles the conflict between the log reader and console writer"
        # this stops the copy to clipboard loop so a command can be sent without random clicks and letters being added
        # there is likely a timing issue here but I don't want to waste more time on this
        while True:
            if (self.__logWriter.isLoopInProgress):
                self.__consoleWriter.stop()
            else:
                self.__consoleWriter.start()

            if (self.__consoleWriter.isLoopInProgress):
                self.__logWriter.stop()
            else:
                self.__logWriter.start()

            time.sleep(0.1)


main = Main()

main.start()
