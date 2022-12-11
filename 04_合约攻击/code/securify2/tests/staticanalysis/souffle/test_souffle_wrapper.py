from securify.staticanalysis.souffle.souffle import is_souffle_available
from securify.staticanalysis.souffle.wrapper import souffle_wrapper

if __name__ == '__main__':
    print(is_souffle_available())
    print(souffle_wrapper(verbose=True, version=True))
