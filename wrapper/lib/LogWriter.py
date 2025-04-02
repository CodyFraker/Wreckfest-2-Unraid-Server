from .LineStore import LineStore
from threading import Thread
import os
import time
import subprocess
from .Line import Line


class LogWriter():
    "Class to take output from the wreckfest server log and write it to a file"

    __loopThread: Thread
    __loopIsPaused: bool = True
    __loopIsInProgress: bool = False

    def __init__(self, filename: str):
        self.__filename = filename
        self.__lineStore = LineStore()

        # check if file exists, if not create it
        if not os.path.exists(self.__filename):
            with open(self.__filename, 'w'):
                pass

        self.__loopThread = Thread(target=self.__loop)
        self.__loopThread.start()

    @property
    def isLoopInProgress(self):
        return self.__loopIsInProgress

    def start(self):
        self.__loopIsPaused = False

    def stop(self):
        self.__loopIsPaused = True

    def __loop(self):
        while True:
            while self.__loopIsPaused:
                time.sleep(0.1)

            self.__loopIsInProgress = True

            self.__writeConsoleOutputToClipboard()
            time.sleep(0.2)
            data = self.__readClipboard()

            lines = data.splitlines()

            newLines = self.__lineStore.getNewLines(lines)
            # write new lines to file
            if len(newLines) > 0:
                self.__appendLinesToFile(newLines)

            self.__loopIsInProgress = False

    def __writeConsoleOutputToClipboard(self):
        # move mouse over window
        subprocess.run(['xdotool', 'mousemove', '50', '50'])
        time.sleep(0.1)
        # the next 3 commands open the context menu, open the edit menu, then select all
        subprocess.run(['xdotool', 'click', '3'])
        time.sleep(0.1)
        subprocess.run(['xdotool', 'type', 'e'])
        time.sleep(0.1)
        subprocess.run(['xdotool', 'type', 's'])
        time.sleep(0.75)
        # the next 3 commands open the context menu, open the edit menu, then copy
        subprocess.run(['xdotool', 'click', '3'])
        time.sleep(0.1)
        subprocess.run(['xdotool', 'type', 'e'])
        time.sleep(0.1)
        subprocess.run(['xdotool', 'type', 'c'])

    def __readClipboard(self):
        result = subprocess.run(
            ['xclip', '-selection', 'clipboard', '-o'], stdout=subprocess.PIPE, universal_newlines=True, text=True)

        return result.stdout

    def __appendLinesToFile(self, lines: list[Line]):
        with open(self.__filename, 'a') as f:
            for line in lines:
                f.write(str(line) + '\n')
