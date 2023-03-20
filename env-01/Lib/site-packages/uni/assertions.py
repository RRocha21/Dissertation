import collections

from uni.checker import check


class MatchSetFailed(Exception):
    '''Raised if the requirements of a MatchSet aren't satisfied.
    '''


class MatchSet:
    '''Defines a set of a spec's that must be matched by the time
    self.check_all completes. Optionally raise failure or return self.success.
    '''
    def __init__(self, querylist=None, raise_failure=False):
        self.querylist = list(querylist or getattr(self, 'querylist', []))
        self.success = None
        self.raise_failure = raise_failure

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.finalize()

    def check(self, obj):
        for query in self.querylist:
            match = check(query, obj)
            if match:
                self.querylist.remove(query)
                return

    def check_all(self, obj_list):
        for obj in obj_list:
            for query in self.querylist:
                if check(query, obj):
                    self.querylist.remove(query)
                    break
        return self.finalize()

    def finalize(self):
        if self.querylist:
            self.success = False
            if self.raise_failure:
                msg = "%d queries didn't match any data"
                raise MatchSetFailed(msg % len(self.querylist))
        else:
            self.success = True
        return self.success


class AssertionFailed(Exception):
    '''Raised if a match assertion fails.
    '''


class AssertionSet:
    '''Defines a sequence of match_spec, assertion_spec 2-tuples. Each
    input datastructure is tested to see if it matches any match_specs. If
    it does, the datastructure is then tested against the corresponding
    assertion_spec's, and AssertionFailed is raised if any fail.
    '''
    def __init__(self, querylist=None, raise_failure=False):
        self.querylist = list(querylist or self.querylist)
        self.success = None
        self.raise_failure = raise_failure
        self.stats = collections.Counter()
        self.failures = []

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.finalize()

    def check(self, obj):
        for match_spec, assertion_spec in self.querylist:
            match = check(match_spec, obj)
            if match:
                if not check(assertion_spec, obj):
                    if self.raise_failure:
                        msg = '%r did not match %r'
                        raise AssertionFailed(msg % (obj, assertion_spec))
                    else:
                        self.stats[False] += 1
                        fail_data = (match_spec, assertion_spec, obj)
                        self.failures.append(fail_data)
                else:
                    self.stats[True] += 1

    def check_all(self, obj_list):
        for obj in obj_list:
            self.check(obj)
        return self.finalize()

    def finalize(self):
        self.success = not bool(self.stats.get(False))
        return self.success