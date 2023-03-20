import re
import types
import operator

from nmmd import TypeDispatcher, DispatchError


class UnhandledOperatorError(Exception):
    pass


class InvalidPath(Exception):
    pass


class InvalidQuery(Exception):
    '''Raised if query is wrong.
    '''


class Dispatcher(TypeDispatcher):

    def prepare(self):
        return dict(self.registry)


class SpecChecker:
    '''Is testing for minimal pattern matching, so should
    evaluate lazily and bail. I.e., this code won't be able to report all
    matches or match failures after a match attempt; to do that would entail
    some changes, but they wouldn't be too difficult, because the
    nmmd.Dispatcher is explicitly designed to accommodate dispatching to
    multiple handler functions.
    '''
    dispatcher = Dispatcher()
    gentype = types.GeneratorType

    # -----------------------------------------------------------------------
    # Top-level checking functions.
    # -----------------------------------------------------------------------
    InvalidPath = InvalidPath

    def path_eval(self, obj, keypath):
        '''Given an object and a mongo-style dotted key path, return the
        object value referenced by that key path.
        '''
        segs = keypath.split('.')
        this = obj
        for seg in segs:
            if isinstance(this, dict):
                try:
                    this = this[seg]
                except KeyError:
                    raise self.InvalidPath()
            elif isinstance(this, (list, tuple)):
                if seg.isdigit():
                    this = this[int(seg)]
            else:
                try:
                    this = getattr(this, seg)
                except AttributeError:
                    raise self.InvalidPath()
        return this

    def check(self, spec, data):
        '''Given a mongo-style spec and some data or python object,
        check whether the object complies with the spec. Fails eagerly.
        '''
        path_eval = self.path_eval
        for keypath, specvalue in spec.items():
            if keypath.startswith('$'):
                optext = keypath
                checkable = data
                args = (optext, specvalue, checkable)
                generator = self.dispatch_operator(*args)
            else:
                try:
                    checkable = path_eval(data, keypath)
                except self.InvalidPath:
                    # The spec referenced an item or attribute that
                    # doesn't exist. Fail!
                    return False
                generator = self.dispatch_literal(specvalue, checkable)
            for result in generator:
                if not result:
                    return False
        return True

    # -----------------------------------------------------------------------
    # Functions for evaluating query literals.
    # -----------------------------------------------------------------------
    def dispatch_literal(self, *args, **kwargs):
        return self.dispatcher.dispatch(*args, **kwargs)

    def handle_literal(self, val, checkable):
        '''This one's tricky...check for equality,
        then for contains.
        '''
        # I.e., spec: {'x': 1}, data: {'x': 1}
        if val == checkable:
            yield True
            return
        # I.e., spec: {'x': 1}, data: {'x': [1, 2, 3]}
        else:
            try:
                yield val in checkable
                return
            except TypeError:
                pass
        yield False

    generic_handler = handle_literal

    def handle_dict(self, dicty, checkable):
        for key, query in dicty.items():
            if key.startswith('$'):
                optext = key
                args = (optext, query, checkable)
                yield from self.dispatch_operator(*args)
            else:
                yield self.check({key: query}, checkable)

    def handle_list(self, listy, checkable):
        yield listy == checkable

    handle_set = handle_tuple = handle_list

    # -----------------------------------------------------------------------
    # Functions for evaluating query operators.
    # -----------------------------------------------------------------------
    UnhandledOperatorError = UnhandledOperatorError

    op_funcs = {

        # Comparison.
        '$in': lambda item, array: item in array,
        '$gte': operator.ge,
        '$gt': operator.gt,
        '$lt': operator.lt,
        '$lte': operator.le,
        '$ne': operator.ne,
        '$nin': lambda item, array: item not in array,
        '$all': lambda a, b: set(b).issubset(set(a)),
    }

    def dispatch_operator(self, optext, spec, checkable):

        # Try handle with builtin operators.
        if optext in self.op_funcs:
            args = (optext, spec, checkable)
            for result in self.handle_operator(*args):
                yield result
            return

        # Fall back to class-level double-dispatch.
        optext = optext.lstrip('$')
        method = getattr(self, 'handle_' + optext, None)
        if method is None:
            raise DispatchError('No method found: %r' % spec)
        results = method(spec, checkable)
        if isinstance(results, self.gentype):
            yield from results
            return
        else:
            yield results
            return

        # If none found, complain.
        msg = 'Encountered unhandled operator: %r' % optext
        raise self.UnhandledOperatorError(msg)

    def handle_operator(self, optext, spec, checkable):
        op = self.op_funcs[optext]
        yield op(checkable, spec)

    def handle_and(self, listy, checkable):
        for spec in listy:
            if not self.check(spec, checkable):
                return False
        return True

    def handle_any(self, listy, checkable):
        for spec in listy:
            if self.check(spec, checkable):
                return True

    handle_or = handle_any

    def handle_nor(self, listy, checkable):
        for spec in listy:
            if self.check(spec, checkable):
                return False

    handle_none = handle_nor

    def handle_not(self, spec, checkable):
        return not self.check(spec, checkable)

    def handle_type(self, spec, checkable):
        checkable_type = type(checkable)
        if checkable_type == spec:
            return True
        elif checkable_type.__name__ == spec:
            return True
        else:
            return False

    def handle_isinstance(self, spec, checkable):
        '''This will have to wait until dynamic loading
        in the dispatcher module is functionalized better.
        '''
        raise NotImplemented()

    def handle_subclass(self, spec, checkable):
        '''This will have to wait until dynamic loading
        in the dispatcher module is functionalized better.
        '''
        raise NotImplemented()

    def handle_exists(self, spec, checkable):
        '''The implementation of this one is weird. By the time
        the {'$exists': True} spec gets to the dispatched
        handler, the key presumably exists.

        So we just parrot the assertion the spec makes. If it
        asserts the key exists, we return True. If it asserts
        the key doesn't exist, we return False, because that
        can't be true.
        '''
        if not isinstance(spec, bool):
            msg = 'The argument of an exists query must be of type bool.'
            raise InvalidQuery(msg)
        return spec


def check(spec, data, checker=SpecChecker()):
    return checker.check(spec, data)
