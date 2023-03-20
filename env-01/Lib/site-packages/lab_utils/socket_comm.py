""" Server/client communication via TCP sockets.
The module implements TCP communication between
a daemon-like :class:`Server` and a simple
:class:`Client`.

The :class:`Server` class is meant to be
run as a daemon-like app. The user should
override the :meth:`~Server.create_parser`
method to define the daemon behaviour upon
reception of a message from a :class:`Client`.
The base class provides support for the
message 'quit', which will terminate the
daemon. Any other message will be met with
a help-like reply.

The :class:`Client` class communicates with
the :class:`Server` sending a text string.

The :class:`ArgumentParser` class and
:class:`MessageError` exception are
necessary to override some unwanted
default behaviour of the
:obj:`argparse` library.

The module is based upon `this tutorial
<https://pymotw.com/2/socket/tcp.html>`_.

Attributes
----------
buffer_size: int, 4096
    Maximum length of a transmitted messages
"""

# Imports
from re import compile
from typing import Pattern
import signal
import socket
import select
import configparser
from os.path import abspath, expanduser
import argparse

# Third party
from zc.lockfile import LockFile, LockError

# Local packages
from lab_utils.custom_logging import getLogger, CustomLogger
from .__project__ import __documentation__ as docs_url

# Maximum length of transmitted messages
buffer_size: int = 4096


class ArgumentParser(argparse.ArgumentParser):
    """ Modifies some annoying behaviours
     of the :obj:`argparse` library. """

    def __init__(self,
                 prog=None,
                 usage=None,
                 description=None,
                 epilog=None,
                 parents=None,
                 formatter_class=argparse.HelpFormatter,
                 prefix_chars='-',
                 fromfile_prefix_chars=None,
                 argument_default=None,
                 conflict_handler='error',
                 add_help=False,
                 allow_abbrev=True):
        """Overrides the
        `default initialization <https://docs.python.org/3/library/argparse.html#add-help>`_
        of :obj:`add_help` to False. It also fixes
        the 'default value is mutable' warning. """

        if parents is None:
            parents = []

        super().__init__(
            prog,
            usage,
            description,
            epilog,
            parents,
            formatter_class,
            prefix_chars,
            fromfile_prefix_chars,
            argument_default,
            conflict_handler,
            add_help,
            allow_abbrev
        )

    def error(self, message: str):
        """ Avoids the call to :func:`sys.exit()`
        when an error is encountered.

        Raises
        ------
        :class:`MessageError`
            Custom exception just for this purpose.
        """
        raise MessageError(message)

    def full_help(self) -> str:
        """ Creates a complete help message for the
        daemon usage. The --help option of :obj:`argparse`
        does not provide the possibility to print a
        monolithic help message including the subparsers.

        Returns
        -------
        str:
            Full help message.
        """
        # Custom message
        full_message = '\nDAEMON HELP\n'

        # Usage and description
        full_message += self.description
        full_message += '\n'
        full_message += self.format_usage()
        full_message += '\n'

        # Retrieve subparsers from parser
        subparsers = [
            subparser
            for action in self._actions
            if isinstance(action, argparse._SubParsersAction)   # noqa
            for _, subparser in action.choices.items()
        ]

        full_message += 'Commands:\n'
        for sp in subparsers:
            # Section
            full_message += '    {:15}   {}\n'.format(sp.prog.split(' ')[1], sp.description)

            for action_group in sp._action_groups:   # noqa
                for op in action_group._group_actions:   # noqa
                    if action_group.title == 'optional arguments':
                        desc = '[{}]'.format(op.option_strings[0])
                    full_message += '        {:15}    {}\n'.format(desc, op.help)
        full_message += '\n'

        # epilog
        full_message += self.epilog

        return full_message


class MessageError(BaseException):
    """ Invalid message. """
    pass


class Server:
    """ Daemon-like TCP server. The server connects
    to the specified :attr:`host` and :attr:`port`
    and locks a :attr:`PID file<lock>` to ensure it
    is the only instance running.

    If successful, the server will then listen
    indefinitely, waiting for a client to connect.
    Upon connection, a :attr:`message` is received
    and passed to the :attr:`parser`. If the message
    is valid, the parser will call the respective
    method. The base class provides only the
    :meth:`quit` method; users should create new
    methods suitable for their needs. These methods
    should always set an appropriate :attr:`reply`,
    which will be then sent back to the client.

    If a message is not valid (i.e. the parser
    does not support it), an error message and a
    complete help string is sent back to the client.
    The help string by the :obj:`argparse` library
    is not complete and hence is overridden by the
    :meth:`ArgumentParser.full_help` method.
    """

    # Flags
    quit_flag: bool = False     #: Internal flag to stop the daemon.

    # TCP configuration
    host: str = 'localhost'             #: Host address.
    port: int = 1507                    #: Connection port.
    sock: socket.SocketType = None      #: Connection socket.
    address: str = None                 #: TCP binding address.
    max_backlog: int = 1                #: TCP connection queue.
    socket_timeout: float = 1.          #: Socket time-out, used for Ctrl+C handling

    # Server variables
    logger: CustomLogger = None         #: Single :class:`~lab_utils.custom_logging.CustomLogger` for the whole class.
    message: str = ''                   #: Message from the client.
    reply: str = ''                     #: Reply to the client.

    # Daemon
    pid_file_name: str = '/tmp/socket_comm.pid'     #: The PID file name
    lock: LockFile = None                           #: :class:`~zc.lockfile.LockFile` object.

    # Message parsing
    namespace: argparse.Namespace = None    #: Container to hold message options.
    parser: ArgumentParser = None           #: Argument parser.
    delimiter_left: chr = None              #: Left delimiter
    delimiter_right: chr = None             #: Left delimiter
    regex: Pattern = None                   #: Parsing pattern.
    # noinspection PyProtectedMember
    sp: argparse._SubParsersAction = None   #: Argument subparser

    def __init__(self,
                 config_file: str = None,
                 pid_file_name: str = None,
                 host: str = None,
                 port: int = None):
        """ Initializes and runs the :class:`Server` object.
        The constructor calls the :meth:`config` method to
        read out the server attributes, and initializes
        the :attr:`logger` and the message :attr:`parser`.
        Finally, the method :meth:`daemonize` tries to
        lock the PID file :attr:`pid_file_name`.

        Parameters
        ----------
        config_file : str, optional
            Configuration file, default is `None`.

        pid_file_name : str, optional
            If given, overrides the default :attr:`PID file name<pid_file_name>`.

        host : int, optional
            If given, overrides the server :attr:`host`.

        port : int, optional
            If given, overrides the server :attr:`port`.

        Raises
        ------
        :class:`configparser.Error`
           Configuration file error
        :class:`LockError`
           The PID file could not be locked (see `here <https://pypi.org/project/zc.lockfile/>`_).
        :class:`OSError`
            Various socket errors, e.g. address or timeout
        """

        # Use a single logger for all server messages
        self.logger = getLogger()

        # Read _config file
        if config_file is not None:
            self.config(config_file)

        # Override PID file
        if pid_file_name is not None:
            self.pid_file_name = pid_file_name

        # Override server address
        if host is not None:
            self.host = host

        if port is not None:
            self.port = port

        # Initialize parser
        self.create_parser()
        self.delimiter_left = '{'
        self.delimiter_right = '}'
        self.regex = compile(" (?![^{dl}{dr}]*{dr})".format(
            dl=self.delimiter_left,
            dr=self.delimiter_right
        ))

        # Lock the PID file, raise LockError if it fails
        self.daemonize()

        # Event flags
        self.quit_flag = False

    def daemonize(self):
        """ Locks a PID file to ensure that a
        single instance of the server is running.
        It is based on the (poorly documented)
        `zc.lockfile
        <https://pypi.org/project/zc.lockfile/>`_
        package.

        Raises
        ------
        :class:`LockError`
           The PID file could not be locked.
        """
        try:
            self.logger.info('Locking PID file {f}'.format(f=self.pid_file_name))
            self.lock = LockFile(
                path=self.pid_file_name,
                content_template='{pid};{hostname}'
            )
        except LockError as e:
            self.logger.error("{}: {}".format(type(e).__name__, e))
            raise

    def config(self, filename: str):
        """ Loads the server configuration from a file.

        Parameters
        ----------
        filename : str
            The file name to be read.

        Raises
        ------
        :class:`configparser.Error`
            If an error happened while parsing the file, e.g. no file was found
        """

        # Expand configuration file path
        filename = abspath(expanduser(filename))

        # Use a logger named like the module itself
        self.logger.info("Loading configuration file %s", filename)

        try:
            # Initialize _config parser and read file
            config_parser = configparser.ConfigParser()
            config_parser.read(filename)

            # Assign values to class attributes
            self.host = config_parser.get(section='Overall', option='host', fallback='localhost')
            self.port = config_parser.getint(section='Overall', option='port', fallback=1507)

        except configparser.Error as e:
            self.logger.error("{}: {}".format(type(e).__name__, e))
            raise

        except BaseException as e:
            # Undefined exception, full traceback to be printed
            self.logger.exception("{}: {}".format(type(e).__name__, e))
            raise

    def start_daemon(self):
        """ Starts the server.
        The server will run in an endless loop until
        the message 'quit' is received. Clients can
        connect to the TCP port and send a text string.
        The message will be parsed by the :attr:`parser`,
        which will call the respective function. If the
        message is invalid, a help string is sent
        to the client.

        The binding to the TCP port might fail for several
        reasons (e.g. the port is already in use by another
        process or requires admin rights), in which an
        :class:`OSError` exception is raised. If the binding
        is successful, the server should be able to
        manage all exceptions, log them, and continue normal
        operations.

        Raises
        ------
        :class:`OSError`
            Various socket errors, e.g. address or timeout
        """

        try:
            # Bind the server to the address
            self.logger.info('Binding to address {h}:{p}'.format(h=self.host, p=self.port))
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.sock.setblocking(False)
            self.sock.bind((self.host, self.port))
            self.address = self.sock.getsockname()[1]
            self.sock.listen(self.max_backlog)
            self.logger.info('Server is now listening, send a \'quit\' message to stop it')

            # Enable signal handling, e.g. catching CTRL+C
            signal.signal(signal.SIGINT, self.signal_handler)

            # Endless loop
            while not self.quit_flag:

                # Wait for client
                # Time-out is necessary to handle Ctrl+C
                readable, _, __ = select.select([self.sock], [], [], self.socket_timeout)

                # Check for Ctrl+C
                if self.quit_flag:
                    break

                # Connection ready?
                if self.sock not in readable:
                    continue
                connection = None
                client_address = None
                try:
                    # Receive message
                    connection, client_address = self.sock.accept()
                    self.logger.debug('Client connected from %s', client_address)
                    self.message = connection.recv(buffer_size).decode().rstrip()

                    # Split message and remove delimiters
                    parsed_message = [item.strip(' {}{}'.format(self.delimiter_left, self.delimiter_right))
                                      for item in self.regex.split(self.message)]
                    self.logger.debug('Message: %s', parsed_message)

                    # Parse message and call appropriate task
                    try:
                        self.reply = ''
                        self.namespace = self.parser.parse_args(
                            args=parsed_message,
                        )
                        self.namespace.func()

                        # If the message is 'quit', make sure we quit regardless
                        # of what the user did to the quit() method
                        self.quit_flag = self.namespace.which == 'quit'

                    except AttributeError as e:
                        self.logger.warning("{}: {}".format(type(e).__name__, e))
                        self.reply = 'Daemon error, maybe you forgot to set the \'which\' argument?\n'
                        self.reply.join('{}: {}'.format(type(e).__name__, e))

                    except MessageError as e:
                        # Invalid message
                        self.logger.warning("{}: {}".format(type(e).__name__, e))
                        self.reply = 'Error! {}\n{}'.format(
                            e,
                            self.parser.full_help()
                        )
                        self.logger.debug('Sending help message to the client')
                    except BaseException as e:
                        # Unknown error
                        self.logger.exception("{}: {}".format(type(e).__name__, e))
                        self.reply = 'Unknown exception! Check daemon log!\n{}: {}'.format(type(e).__name__, e)
                    else:
                        # All good
                        self.logger.debug('Sending reply: %s', repr(self.reply))

                    # Send reply to client
                    # TODO: check that len(self.reply) < buffer_size
                    connection.send(self.reply.encode())

                except OSError as e:
                    self.logger.error("{}: {}".format(type(e).__name__, e))
                    self.logger.error("Server could recover and is still listening")

                except BaseException as e:
                    self.logger.exception("{}: {}".format(type(e).__name__, e))
                    self.logger.error("Unexpected exception, server could recover and is still listening")

                finally:
                    # Close connection
                    self.logger.debug('Closing connection to client %s', client_address)
                    connection.close()

        except OSError as e:
            self.logger.error("{}: {}".format(type(e).__name__, e))
            raise

        except BaseException as e:
            self.logger.exception("Unexpected exception")
            self.logger.exception("{}: {}".format(type(e).__name__, e))
            raise

        finally:
            # Server's End-Of-Life
            self.close()

    def close(self):
        """ Releases the PID lock file
        and the TCP socket. """
        if self.address is not None:
            try:
                self.logger.info('Closing socket')
                self.sock.close()
            except OSError as e:
                self.logger.error('Something went wrong... {}: {}'.format(type(e).__name__, e))

        if self.lock is not None:
            try:
                self.logger.info('Releasing PID file')
                self.lock.close()
            except ValueError as e:
                self.logger.error('Something went wrong... {}: {}'.format(type(e).__name__, e))

    def create_parser(self):
        """ Configures the message :attr:`parser`,
        which will call the appropriate method
        upon reception of a message. Other
        arguments given to the parser will be
        available in the :attr:`namespace`.

        As an example, the subparser for the message
        'quit' is implemented. The user should override
        the :meth:`quit` method, as well as implement
        other methods for the particular daemon tasks.
        """
        # Initialize the parser
        self.parser = ArgumentParser(
            prog='daemon',
            description='socket_comm daemon example, the user should override this',
            add_help=False,
            epilog='Check out the package documentation for more information:\n{}'.format(docs_url)
        )
        self.sp = self.parser.add_subparsers(title='command', description='Daemon actions')

        # One subparser per task: 1. QUIT
        sp_quit = self.sp.add_parser(
            name='quit',
            description='stops the daemon'
        )
        sp_quit.set_defaults(
            func=self.quit,
            which='quit'
        )

    def quit(self):
        """ User-defined task example. The method is called
        by the  :attr:`parser` when the message 'quit'
        is received. For the base class, it just
        says goodbye to the client. Users should
        override it to do proper clean-up of their daemon.
        """
        # User should add clean-up code here
        self.logger.info('Cleaning up...')

        # One must always be polite to the client
        self.reply = 'Goodbye!'

    def signal_handler(self, _, __):
        self.logger.info('Signal Terminator Interrupted! Trying to terminate gracefully...')

        # 1. Set the quitting flag, the server should terminate in less than socket_timeout seconds
        self.quit_flag = True

        # 2. Call clean-up method
        self.quit()


class Client:
    """ Simple TCP client to communicate with a
    running :class:`Server`. It sends a
    message and receives the reply from the
    server.
    """

    # Attributes
    host: str = 'localhost'     #: Host address.
    port: int = 1507            #: Connection port.

    def __init__(
            self,
            config_file: str = None,
            host: str = None,
            port: int = None
    ):
        """ Initializes the :class:`Client` object. If a
        :paramref:`~Client.__init__.config_file`
        is given, the constructor calls the
        :meth:`~.Client.config` method and
        overrides the default attributes. If the
        parameters :paramref:`host` and
        :paramref:`port` are given, they will
        override the configuration file.

        Parameters
        ----------
        config_file : str, optional
            Configuration file name, default is `None`. Same as
            See the example TODO.

        host : str, optional
            Host address, default is `None`.

        port : int, optional
            Connection port, default is `None`.


        Raises
        ------
        :class:`configparser.Error`
            If a configuration file name was given, the method
            :meth:`config` can fail raising this exception.
        """

        # Read configuration file
        if config_file is not None:
            self.config(config_file)

        # Override attributes, if given
        if host is not None:
            self.host = host

        if port is not None:
            self.port = port

    def config(self, config_file: str):
        """ Loads the TCP configuration from the file
        :paramref:`~Client.config.config_file`.

        The method reads the file using the library
        :obj:`configparser`..

        Parameters
        ----------
        config_file : str
            TCP configuration file, full path.

        Raises
        ------
        :class:`configparser.Error`
            Error while parsing the file, e.g. no file was found,
            a parameter is missing or it has an invalid value.
        """

        # Expand configuration file path
        config_file = abspath(expanduser(config_file))
        getLogger().info("Loading configuration file %s", config_file)

        try:
            # Initialize _config parser and read file
            config_parser = configparser.ConfigParser()
            config_parser.read(config_file)

            # Assign values to class attributes
            self.host = config_parser.get(section='Overall', option='host')
            self.port = config_parser.getint(section='Overall', option='port')

        except configparser.Error as e:
            getLogger().error("{}: {}".format(type(e).__name__, e))
            raise

        except BaseException as e:
            # Undefined exception, full traceback to be printed
            getLogger().exception("{}: {}".format(type(e).__name__, e))
            raise

        else:
            getLogger().info("Configuration file loaded")

    def send_message(self, message: str) -> str:
        """ Complete communication process. Connects
        to the :class:`Server`, sends a
        :paramref:`~Client.send_message.message`,
        gets the reply and closes the connection.

        Parameters
        ----------
        message : str
            Message for the :class:`Server`.

        Raises
        ------
        :class:`OSError`
            Various socket errors, e.g. address or timeout

        Returns
        -------
        str
            Reply from the server
        """

        # Get the logger
        getLogger().info('Sending message to the server: %s', message)

        try:
            # Connect to the server
            sock = socket.create_connection((self.host, self.port))

            # Send message
            # TODO: check message length
            sock.send(message.encode())

            # Get reply
            reply = sock.recv(buffer_size).decode()
            getLogger().info('Reply received: %s', reply)

            # Close the connection
            sock.close()

        except OSError as e:
            getLogger().error("{}: {}".format(type(e).__name__, e))
            raise

        except BaseException as e:
            # Undefined exception, full traceback to be printed
            getLogger().exception("{}: {}".format(type(e).__name__, e))
            raise

        else:
            return reply
