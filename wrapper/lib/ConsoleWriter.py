from threading import Thread
import time
import subprocess

from lib.Constants import USER_INPUT_SUFFIX, USER_INPUT_TIMESTAMP_FORMAT


class ConsoleWriter():
    "Class to take input from the user and write it to the console"

    __loopThread: Thread
    __loopIsPaused: bool = True

    __loopIsInProgress = False

    def __init__(self):
        self.__loopThread = Thread(target=self.__loop)
        self.__loopThread.start()

    @property
    def isLoopInProgress(self):
        return self.__loopIsInProgress

    def start(self):
        self.__loopIsPaused = False

    def stop(self):
        self.__loopIsPaused = True

    def __getUserInputStringSuffix(self):
        "Returns the user input string suffix with the current timestamp"
        return USER_INPUT_SUFFIX + time.strftime(USER_INPUT_TIMESTAMP_FORMAT, time.localtime())

    def __loop(self):
        while True:
            userInput = input()

            if (userInput.strip() == ''):
                continue

            self.__loopIsInProgress = True

            # wait for unpause before continuing
            while self.__loopIsPaused:
                time.sleep(0.1)

            self.__sendText(userInput)

            # we are sending a timestamp as well so we have a reference for other untimestamped logs
            self.__sendText(self.__getUserInputStringSuffix())

            subprocess.run(['xdotool', "key", "Return"])

            self.__loopIsInProgress = False

    def __sendText(self, text: str):
        subprocess.run(['xdotool', "type", "--delay", "10", text])
        time.sleep(0.1)
        subprocess.run(['xdotool', "key", "Return"])
        time.sleep(0.1)
