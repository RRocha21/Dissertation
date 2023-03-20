""" Implements a custom logging service. The logging setup
is based upon the standard Python :obj:`logging` library
and offers some advantages:

- Standard logging across multiple apps using this module.
- Ease of use and configuration, with only necessary options.
- Extra functionality:

   - E-mail notification over TLS.
   - Coloured output to a terminal
   - Improved file rotation naming.
   - Logging over TCP socket compatible with the
     :obj:`~lab_utils.socket_comm` module.

Attributes
---------
SUCCESS: int
    New log level (25) intended to report successful
    events to Slack, between INFO (20) and WARNING (30).

"""

# Imports
import logging
from logging import handlers
from queue import Queue
from sys import stdout
from atexit import register
from typing import Optional, TextIO, Tuple, List
import configparser
from os import makedirs
from os.path import abspath, expanduser, sep
from time import strftime
from datetime import datetime
import errno
import smtplib
from email.message import EmailMessage

# Third party
from slacker_log_handler import SlackerLogHandler, NoStacktraceFormatter
from pythonjsonlogger.jsonlogger import JsonFormatter

# New logging level: success, between WARNING and INFO
# It is meant to be used to report non-error events to Slack
SUCCESS = 25

# App name, will be the default logger name when calling getLogger()
APP_NAME = 'root'


def string_to_bool(s: str) -> bool:
    """ Parses a variety of strings (e.g. 'true' or '1') to a boolean.

    Parameters
    ----------
    s: str
        The string to parse

    Returns
    -------
    bool:
        True if :paramref:`s` is one of:

          - 'true'
          - '1'
          - 't'
          - 'y'
          - 'yes'
          - 'on'
    """
    return s.lower() in ['true', '1', 't', 'y', 'yes', 'on']


class ColoredFormatter(logging.Formatter):
    """ Console :class:`formatter<logging.Formatter>`
    that prepends the coloured severity level of the
    message. Based upon this
    `gist <https://gist.github.com/hit9/5635505>`_.
    """

    colours = {
        'black':    30,
        'red':      31,
        'green':    32,
        'yellow':   33,
        'blue':     34,
        'magenta':  35,
        'cyan':     36,
        'white':    37,
        'bgred':    41,
        'bggrey':   100,
    }                           #: Terminal colour codes.
    colour_map = {
        'INFO':         'cyan',
        'WARNING':      'yellow',
        'ERROR':        'red',
        'CRITICAL':     'bgred',
        'EXCEPTION':    'bgred',
        'DEBUG':        'bggrey',
        'SUCCESS':      'green'
    }                           #: Colour mapping.
    prefix = '\033['            #: Prefix to modify terminal output colour.
    suffix = '\033[0m'          #: Suffix to modify terminal output colour.

    def format(self, record: logging.LogRecord) -> str:
        """ Prepends a fixed-length, coloured trailer with the
        log level.

        Parameters
        ----------
        record: :class:`~logging.LogRecord`
            The record to be logged.

        Returns
        -------
        str:
            The formatted message
        """

        # Get the plain message from the parent formatter
        message = super(ColoredFormatter, self).format(record)

        # Get the colour code
        colour = self.colour_map.get(record.levelname, 'white')
        if colour not in self.colours:
            colour = 'white'
        colour_code = self.colours[colour]

        # Build coloured header
        coloured_header = '%s%dm%s%s' % (
            self.prefix,
            colour_code,
            record.levelname,
            self.suffix,
        )

        # Return formatted message, properly padded
        return coloured_header + ''.ljust(9-len(record.levelname), ' ') + message


class CustomTimedRotatingFileHandler(logging.handlers.TimedRotatingFileHandler):
    """ Variation of :class:`~logging.handlers.TimedRotatingFileHandler`. The
    handler will produce daily log files to a given directory, appending the
    date to a given base name."""

    # Attributes
    path: str = None        #: Parent directory to save all logs.
    basename: str = None    #: Complete file base name where date will be appended, without extension.
    extension: str = None   #: Log file extension.

    # Inherited attributes
    stream: TextIO = None   #: File stream
    rolloverAt = None       #: Next rollover time

    def __init__(self, path: str, basename: str, extension: str = '.log'):
        """ Calls the parent constructor and creates the logging
        directory, if it does not exist.

        Parameters
        ----------
        path: str
            Parent directory to save all logs.

        basename: str
            File base name where date will be appended, without extension.

        extension: str, optional
            Log file extension, default is 'log'.

        Raises
        ------
        :class:`OSError`:
            The logging directory could not be created. The handler should
            not be used if this exception is raised.
        """

        # Assign attributes
        self.path = abspath(expanduser(path))
        self.basename = self.path + sep + basename
        self.extension = extension

        # Create logging directory if it does not exist
        try:
            makedirs(self.path)
        except OSError as e:
            if e.errno != errno.EEXIST:
                logging.error("{}: {}".format(type(e).__name__, e))
                raise

        super(CustomTimedRotatingFileHandler, self).__init__(
            filename=self.basename + '_' + strftime("%Y-%m-%d") + self.extension,
            when='midnight',
            delay=True,
            utc=False,
        )

    def doRollover(self):
        """
        Rotates log files on daily basis. The file name of the current
        logfile is :attr:`basename` + :func:`~time.strftime`
        + :attr:`extension`, with time format '%Y-%m-%d'.
        """
        # Close current file
        if self.stream:
            self.stream.close()

        # get the time that this sequence started at and make it a TimeTuple
        self.stream = open(self.basename + '_' + strftime("%Y-%m-%d") + self.extension, 'a')

        # Next rollover
        self.rolloverAt = self.computeRollover(datetime.now().timestamp())  # noqa


class TlsSMTPHandler(logging.handlers.SMTPHandler):
    """ :obj:`~logging.handlers.SMTPHandler`
    with TLS support. Based upon this
    `gist <http://mynthon.net/howto/-/python/python%20-%20logging.SMTPHandler-how-to-use-gmail-smtp-server.txt>`_.
    """

    # Inherited attributes, defined to avoid PyCharm warnings
    mailport: int = None        #: Mail port (inherited).
    mailhost: str = None        #: Mail provider (inherited).
    fromaddr: str = None        #: Sender address (inherited).
    toaddrs: List[str] = None   #: Recipients addresses (inherited).
    username: str = None        #: Login username (inherited).
    password: str = None        #: Login password (inherited).

    def emit(self, record):
        """
        Emits a record. Opens a TLS SMTP connection using the
        :obj:`smtplib` library and sends an
        :class:`~email.message.EmailMessage`.
        """
        # Open connection
        port = self.mailport
        if not port:
            port = smtplib.SMTP_PORT
        smtp = smtplib.SMTP(self.mailhost, port)

        if self.username:
            smtp.ehlo()  # for tls add this line
            smtp.starttls()  # for tls add this line
            smtp.ehlo()  # for tls add this line
            smtp.login(self.username, self.password)

        # Build email message
        msg = EmailMessage()
        msg.set_content(self.format(record))
        msg['Subject'] = self.getSubject(record)
        msg['To'] = ', '.join(self.toaddrs)
        msg['From'] = self.fromaddr

        smtp.send_message(msg)
        smtp.quit()


class NonPickledSocketHandler(logging.handlers.SocketHandler):
    """ Socket handler that sends non-pickled strings. Such strings
    are compatible with a :class:`~lab_utils.socket_comm.Server`
    listening on the appropriate TCP port."""

    def emit(self, record: logging.LogRecord):
        """
        Encodes a :paramref:`~NonPickledSocketHandler.emit.record`
        and writes it to the socket. If there is an error with the
        socket, silently drops the packet. If there was a problem
        with the socket, re-establishes the socket.

        Parameters
        ----------
        record: :class:`~logging.LogRecord`
            The record to be emitted.
        """
        try:
            msg = self.format(record)
            self.send(msg.encode())
        except BaseException:
            self.handleError(record)


class CustomLogger(logging.Logger):
    """ Custom logging class based on the default Python
    :class:`~logging.Logger`. It introduces the new
    logging level :attr:`.SUCCESS` = 25, meant to be used
    to notify Slack about important, non-error events."""

    def __init__(self, name, level=logging.NOTSET):
        """ Calls the parent constructor and adds
        the :attr:`.SUCCESS` = 25 logging level."""
        super(CustomLogger, self).__init__(name, level)

    def success(self, message, *args, **kws):
        """ Creates a log entry with level :attr:`.SUCCESS`, similar
         to the standard :meth:`~logging.Logger.error` and
         :meth:`~logging.Logger.info`. """
        # Yes, logger takes its '*args' as 'args'.
        self._log(SUCCESS, message, args, **kws)


def getLogger(name: Optional[str] = None) -> CustomLogger: # noqa
    """ Overrides the Python standard :func:`logging.getLogger`
    to fix type completion hints, referring them to
    :class:`CustomLogger` instead of :class:`~logging.Logger`.
    Taken from a StackOverflow
    `question <https://stackoverflow.com/questions/51400965/in-python-how-to-i-get-an-extended-class-element-to-show-up-in-autocomplete/51403572>`_.

    Parameters
    ----------
    name: str, optional
        The logger name

    Returns
    -------
    :class:`CustomLogger`
        A named instance of the logger.
    """
    if name is None:
        name = APP_NAME
    _logger: CustomLogger = logging.getLogger(name) # noqa
    return _logger


def configure_logging(
        config_file: str = None,
        fallback: bool = False,
        logger_name: str = 'root',
        log_level: int = None
):
    """ Sets up the custom logger. Loads the configuration
    from :paramref:`~configure_logging.config_file` using the
    :obj:`configparser` library.

    Parameters
    ----------
    config_file : str
        Configuration file name.

    fallback: bool, optional
        If 'True' and the logger setup fails, fall back to the default
        :class:`~logging.Logger`.

    logger_name : str, optional
        Logger name.

    log_level: int, optional
        Initial logging level, overrides the configuration file.

    Raises
    ------
    :class:`configparser.Error`
        Error while parsing the file, e.g. no file was found,
        a parameter is missing or it has an invalid value.
    """

    # Expand configuration file path
    if config_file is not None:
        config_file = abspath(expanduser(config_file))

    # Create a list of handlers to populate
    handlers_list = []

    # Set custom logging class
    logging.setLoggerClass(CustomLogger)

    # Create new logging level
    logging.SUCCESS = SUCCESS  # between WARNING and INFO
    logging.addLevelName(SUCCESS, 'SUCCESS')

    # Set app name
    global APP_NAME
    APP_NAME = logger_name

    # Load the configuration file
    try:
        # Initialize config parser and read file
        config_parser = configparser.ConfigParser()
        if config_file is not None:
            config_parser.read(config_file)

        # Console handler
        if string_to_bool(config_parser.get(section='ConsoleLogger', option='active', fallback='1')):
            console_handler = logging.StreamHandler(stream=stdout)
            console_handler.setLevel(config_parser.get(section='ConsoleLogger', option='log_level', fallback='INFO'))
            if string_to_bool(config_parser.get(section='ConsoleLogger', option='use_coloured_output', fallback='1')):
                console_handler.setFormatter(ColoredFormatter(
                    fmt='%(asctime)s  %(name)-20s %(module)-30s %(funcName)-25s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                ))
            else:
                console_handler.setFormatter(logging.Formatter(
                    fmt='%(levelname)-9s %(asctime)s  %(name)-20s %(module)-20s %(funcName)-20s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                ))

            handlers_list.append(console_handler)

        # File handler
        if string_to_bool(config_parser.get(section='FileLogger', option='active', fallback='0')):
            try:
                file_handler = CustomTimedRotatingFileHandler(
                    path=config_parser.get(section='FileLogger', option='log_path'),
                    basename=config_parser.get(section='FileLogger', option='log_basename'),
                    extension=config_parser.get(section='FileLogger', option='log_extension'),
                )
                file_handler.setLevel(config_parser.get(section='FileLogger', option='log_level'))
                file_handler.setFormatter(JsonFormatter(
                    fmt='%(asctime)s %(levelname)s %(name)s %(module)s %(funcName)s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                ))
                handlers_list.append(file_handler)
            except BaseException as e:
                print("{}: {}".format(type(e).__name__, e))
                print('File logger disabled')

        # Alarm handler
        if string_to_bool(config_parser.get(section='AlarmLogger', option='active', fallback='0')):
            # Get port
            if config_parser.get(section='AlarmLogger', option='port') == 'default':
                port = handlers.DEFAULT_TCP_LOGGING_PORT    # 9020
            else:
                port = config_parser.getint(section='AlarmLogger', option='port')

            alarm_handler = NonPickledSocketHandler(
                host='localhost',
                port=port
            )
            alarm_handler.setLevel(config_parser.get(section='AlarmLogger', option='log_level'))
            alarm_handler.setFormatter(logging.Formatter(
                fmt='{%(name)s}'
                    ' --date {%(asctime)s}'
                    ' --level {%(levelname)s}'
                    ' --app {%(name)s}'
                    ' --module {%(module)s}'
                    ' --function {%(funcName)s}'
                    ' --message {%(message)s}',
                datefmt='%Y-%m-%d %H:%M:%S',
            ))
            handlers_list.append(alarm_handler)

        # SMTP handler for email notifications
        if string_to_bool(config_parser.get(section='MailHandler', option='active', fallback='0')):
            try:
                # Read credentials from local file
                with open(abspath(expanduser(config_parser.get(section='MailHandler', option='credentials_file'))))\
                        as f:
                    credentials: Tuple[str, str] = tuple(filter(None, f.read().rstrip().split('\n', 1))) # noqa

                # Parse list of recipients
                list_of_rec = config_parser.get(section='MailHandler', option='recipients')
                recipients = list(filter(None, (x.strip() for x in list_of_rec.splitlines())))

                mail_handler = TlsSMTPHandler(
                    mailhost=(
                        config_parser.get(section='MailHandler', option='mail_host'),
                        config_parser.getint(section='MailHandler', option='port')
                    ),
                    fromaddr=config_parser.get(section='MailHandler', option='sender'),
                    toaddrs=recipients,
                    subject=config_parser.get(section='MailHandler', option='subject'),
                    credentials=credentials,
                )
                mail_handler.setLevel(config_parser.get(section='MailHandler', option='log_level'))
                mail_handler.setFormatter(logging.Formatter(
                    fmt='%(asctime)s %(levelname)s %(name)s %(module)s %(funcName)s %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                ))

            except BaseException as e:
                print("{}: {}".format(type(e).__name__, e))
                print('The SMTP handler will be disabled')

            else:
                handlers_list.append(mail_handler)

        # Slack handler
        if string_to_bool(config_parser.get(section='SlackLogger', option='active', fallback='0')):
            try:
                # Read API key from local file
                with open(abspath(expanduser(config_parser.get(section='SlackLogger', option='api_file')))) as f:
                    slack_api = f.read().rstrip()

                slack_handler = SlackerLogHandler(
                    api_key=slack_api,
                    channel=config_parser.get(section='SlackLogger', option='channel'),
                    username=config_parser.get(section='SlackLogger', option='user'),
                    fail_silent=False,
                    stack_trace=True,
                )
                slack_formatter = NoStacktraceFormatter(
                    fmt='%(asctime)s   %(levelname)s   %(name)s   %(module)s   %(funcName)s   %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                )
                slack_handler.setFormatter(slack_formatter)
                slack_handler.setLevel(config_parser.get(section='SlackLogger', option='log_level'))
                handlers_list.append(slack_handler)

            except BaseException as e:
                print("{}: {}".format(type(e).__name__, e))
                print('The Slack handler will be disabled')

        # Set up logging queue to decouple the loggers and the main app activity
        que = Queue(-1)  # no limit on size
        qh = logging.handlers.QueueHandler(que)
        listener = logging.handlers.QueueListener(
            que,
            *handlers_list,
            respect_handler_level=True,
        )

        # Add queue handler to the default logger
        root_logger = logging.getLogger()
        root_logger.setLevel(logging.DEBUG)
        root_logger.addHandler(qh)

        # Start the listener, and register it to stop automatically at exit
        listener.start()
        register(listener.stop)

    except configparser.Error as e:
        print("{}: {}".format(type(e).__name__, e))
        if not fallback:
            raise

    except BaseException as e:
        # Undefined exception, full traceback to be printed
        print("{}: {}".format(type(e).__name__, e))
        if not fallback:
            raise

    else:
        logger = logging.getLogger(name=logger_name)
        if log_level is not None:
            logger.setLevel(log_level)
        logger.info('Logging system set up and running')
        logger.debug('Active handlers:')
        for handler in handlers_list:
            logger.debug('  {}'.format(handler))
        return

    # Something went wrong
    print('Default logger will be used')
    logging.setLoggerClass(logging.Logger)
    logging.basicConfig()
