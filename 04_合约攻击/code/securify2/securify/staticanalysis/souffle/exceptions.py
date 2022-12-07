class SouffleError(Exception):
    message = "Error during souffle execution: "

    def __init__(self, command, return_code, stdin_data, stdout_data, stderr_data, message=None):
        if message is not None:
            self.message = message
        self.command = command
        self.return_code = return_code
        self.stdin_data = stdin_data
        self.stderr_data = stderr_data
        self.stdout_data = stdout_data

    def __str__(self):
        return f"{self.message} \n{self.stdout_data}\n{self.stderr_data}"
