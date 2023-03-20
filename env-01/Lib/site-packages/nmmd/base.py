'''We're dealing with two types of dispatchers here. One is the
decorator-based dispatcher that can handle args passed into the decorator.
The other does everything by calling user-defined functions to generate
possible names of the dispatchable methods, with no decorator nonsense
required. But ideally there should be an easy migration path from one to
the other if necessary.

UPDATE: Ok, there are tree types of dispatchers. Also need one that can
be defined at the module level, then used to dispatch in a way that treats
each class as a distinct environment for dispatchery.


class Dispatcher(Dispatcher):

    def prepare(self):
        for invok


class State1:

    @dispatcher('a', 'b', 'c')
    def handler1(self, *stuff):
        return State2('cow')

    @dispatcher('e', 'f', 'g')
    def handler2(self, *stuff):
        return State2('pig')


class State2:

    @dispatcher('f')
    def handler1(self, *stuff):
        pass

    @dispatcher('h', 'i', 'j')
    def handler2(self, *stuff):
        pass

'''
import types
import pickle
import inspect
import functools
import collections

from hercules import CachedAttr, CachedClassAttr, NoClobberDict


class DispatchError(Exception):
    '''Raised when someone does something silly, like
    dispatch two conlicting handlers to process the same
    stream input.
    '''


class DispatchInterrupt(Exception):
    '''Raise to stop dispatcher trying additional dispatch methods.
    '''


class ImplementationError(Exception):
    '''Raise if subclass does stuff wrong.
    '''

def try_delegation(method):
    '''This decorator wraps descriptor methods with a new method that tries
    to delegate to a function of the same name defined on the owner instance
    for convenience for dispatcher clients.
    '''
    @functools.wraps(method)
    def delegator(self, *args, **kwargs):
        if self.try_delegation:
            # Try to dispatch to the instance's implementation.
            inst = getattr(self, 'inst', None)
            if inst is not None:
                method_name = (self.delegator_prefix or '') + method.__name__
                func = getattr(inst, method_name, None)
                if func is not None:
                    return func(*args, **kwargs)

        # Otherwise run the decorated func.
        return method(self, *args, **kwargs)

    return delegator


class BaseDispatcher:
    DispatchError = DispatchError
    DispatchInterrupt = DispatchInterrupt
    GeneratorType = types.GeneratorType

    # Whether to run multiple matching methds or bail after
    # the first (default).
    multi = False

    @CachedAttr
    def dispatch_data(self):
        try:
            return self.prepare()
        except RuntimeError:
            msg ='''
Don't reference self.dispatch_data inside self.prepare,
because self.dispatch_data references self.prepare. Instead use
self.registry.'''
            raise ImplementationError(msg.strip())

    def prepare(self):
        raise NotImplemented()

    def get_method(self):
        raise NotImplemented()

    def dispatch(self, *args, **kwargs):
        raise NotImplemented()


class Dispatcher(BaseDispatcher):
    '''Implements the base functionality for dispatcher types.
    The node instances delegate their dispatch functions to
    subclasses of Dispatcher.
    '''
    __slots__ = tuple()

    def __init__(self, delegate=True, prefix=None):
        self.try_delegation = delegate
        self.delegator_prefix = prefix

    def __call__(self, *args, **kwargs):
        return self._make_decorator(*args, **kwargs)

    def __get__(self, inst, cls=None):
        self.inst = inst
        return self

    def _make_decorator(self, *args, **kwargs):
        def decorator(method):
            self.register(method, args, kwargs)
            return method
        return decorator

    loads = pickle.loads
    dumps = pickle.dumps

    @CachedAttr
    def registry(self):
        return []

    def dump_invoc(self, *args, **kwargs):
        return self.dumps((args, kwargs))

    def load_invoc(self, *args, **kwargs):
        return self.loads((args, kwargs))

    # ------------------------------------------------------------------------
    # Overridables begin here.
    # ------------------------------------------------------------------------
    @try_delegation
    def register(self, method, args, kwargs):
        '''Given a single decorated handler function,
        prepare, append desired data to self.registry.
        '''
        invoc = self.dump_invoc(*args, **kwargs)
        self.registry.append((invoc, method.__name__))

    @try_delegation
    def prepare(self):
        '''Given all the registered handlers for this
        dispatcher instance, return any data required
        by the dispatch method.

        Can be overridden to provide more efficiency,
        simplicity, etc.
        '''
        return self.registry

    @try_delegation
    def gen_methods(self, *args, **kwargs):
        '''Find all method names this input dispatches to. This method
        can accept *args, **kwargs, but it's the gen_dispatch method's
        job of passing specific args to handler methods.
        '''
        dispatched = False
        for invoc, methodname in self.registry:
            args, kwargs = self.loads(invoc)
            yield getattr(self.inst, methodname), args, kwargs
            dispatched = True

        if dispatched:
            return

        # Try the generic handler.
        generic_handler = getattr(self.inst, 'generic_handler', None)
        if generic_handler is not None:
            yield generic_handler, args, kwargs

        # Give up.
        msg = 'No method was found for %r on %r.'
        raise self.DispatchError(msg % ((args, kwargs), self.inst))

    @try_delegation
    def get_method(self, *args, **kwargs):
        '''Find the first method this input dispatches to.
        '''
        for method in self.gen_methods(*args, **kwargs):
            return method
        msg = 'No method was found for %r on %r.'
        raise self.DispatchError(msg % ((args, kwargs), self.inst))

    @try_delegation
    def dispatch(self, *args, **kwargs):
        '''Find and evaluate/return the first method this input dispatches to.
        '''
        for result in self.gen_dispatch(*args, **kwargs):
            return result

    @try_delegation
    def gen_dispatch(self, *args, **kwargs):
        '''Find and evaluate/yield every method this input dispatches to.
        '''
        dispatched = False
        for method_data in self.gen_methods(*args, **kwargs):
            dispatched = True

            result = self.apply_handler(method_data, *args, **kwargs)
            yield result
            # return self.yield_from_handler(result)
        if dispatched:
            return
        msg = 'No method was found for %r on %r.'
        raise self.DispatchError(msg % ((args, kwargs), self.inst))

    @try_delegation
    def apply_handler(self, method_data, *args, **kwargs):
        '''Call the dispatched function, optionally with other data
        stored/created during .register and .prepare

        The naivette in this function is likely source of future pain. It
        doesn't do very smart things when the decorator invocation AND the
        dispatcher.dispatch invocation both pass arguments.
        '''
        kwargs = NoClobberDict(kwargs)
        if isinstance(method_data, tuple):
            len_method = len(method_data)
            method = method_data[0]
            if 1 < len_method:
                args += method_data[1]
            if 2 < len_method:
                kwargs.update(method_data[2])
        else:
            method = method_data
        return method(*args, **kwargs)

    @try_delegation
    def yield_from_handler(self, result):
        '''Given an applied function result, yield from it.
        '''
        return result


def dedupe(gen):
    @functools.wraps(gen)
    def wrapped(*args, **kwargs):
        seen = set()
        for result in gen(*args, **kwargs):
            if result not in seen:
                seen.add(result)
                yield result
    return wrapped


class TypeDispatcher(Dispatcher):
    '''Dispatches to a named method by inspecting the invocation, usually
    the type of the first argument.

    Note this dispatcher doesn't use .prepare or .register, which could
    cause caching bugs when the dispatcher is used from different instances.
    '''
    # It makes sense to go from general/commonplace to specific/rare,
    # so we try to dispatch by type, then bu interface, like iterableness.
    builtins = __builtins__
    types = types
    collections = collections

    abc_types = set([
        'Hashable',
        'Iterable',
        'Iterator',
        'Sized',
        'Container',
        'Callable',
        'Set',
        'MutableSet',
        'Mapping',
        'MutableMapping',
        'MappingView',
        'KeysView',
        'ItemsView',
        'ValuesView',
        'Sequence',
        'MutableSequence',
        'ByteString'])

    interp_types = set([
        'BuiltinFunctionType',
        'BuiltinMethodType',
        'CodeType',
        'DynamicClassAttribute',
        'FrameType',
        'FunctionType',
        'GeneratorType',
        'GetSetDescriptorType',
        'LambdaType',
        'MappingProxyType',
        'MemberDescriptorType',
        'MethodType',
        'ModuleType',
        'SimpleNamespace',
        'TracebackType'])

    # ------------------------------------------------------------------------
    # Plumbing.
    # ------------------------------------------------------------------------
    method_prefix = 'handle_'

    @CachedAttr
    def _method_prefix(cls):
        return getattr(cls, 'method_prefix', 'handle_')

    # ------------------------------------------------------------------------
    # Overridables.
    # ------------------------------------------------------------------------
    @try_delegation
    def gen_method_keys(self, *args, **kwargs):
        '''Given a node, return the string to use in computing the
        matching visitor methodname. Can also be a generator of strings.
        '''
        token = args[0]
        for mro_type in type(token).__mro__[:-1]:
            name = mro_type.__name__
            yield name

    @try_delegation
    @dedupe
    def gen_methods(self, *args, **kwargs):
        '''Find all method names this input dispatches to.
        '''
        token = args[0]
        inst = self.inst
        prefix = self._method_prefix
        for method_key in self.gen_method_keys(*args, **kwargs):
            method = getattr(inst, prefix + method_key, None)
            if method is not None:
                yield method

        # Fall back to built-in types, then types, then collections.
        typename = type(token).__name__
        yield from self.check_basetype(
            token, typename, self.builtins.get(typename))

        for basetype_name in self.interp_types:
            yield from self.check_basetype(
                token, basetype_name, getattr(self.types, basetype_name, None))

        for basetype_name in self.abc_types:
            yield from self.check_basetype(
                token, basetype_name, getattr(self.collections, basetype_name, None))

        # Try the generic handler.
        yield from self.gen_generic()

    generic_handler_aliases = (
        'handle_anything', 'generic_handler', 'generic_handle')

    @try_delegation
    def gen_generic(self):
        for alias in self.generic_handler_aliases:
            generic_handler = getattr(self.inst, alias, None)
            if generic_handler is not None:
                yield generic_handler

    @try_delegation
    def check_basetype(self, token, basetype_name, basetype):
        if basetype is None:
            return
        if not isinstance(token, basetype):
            return
        for name in (basetype_name, basetype.__name__):
            method_name = self._method_prefix + name
            method = getattr(self.inst, method_name, None)
            if method is not None:
                yield method
