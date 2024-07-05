import logging


class Logger:
    def __init__(self, name, level=logging.INFO, stdout=False):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)

        if stdout:
            self.logger.addHandler(logging.StreamHandler())

        f_handler = logging.FileHandler(f"{name}.log", mode="w+")
        f_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        f_handler.setFormatter(f_format)
        self.logger.addHandler(f_handler)

    def debug(self, msg):
        self.logger.debug(msg)

    def info(self, msg):
        self.logger.info(msg)
        
    def warning(self, msg):
        self.logger.warning(msg)

    def error(self, msg):
        self.logger.error(msg)