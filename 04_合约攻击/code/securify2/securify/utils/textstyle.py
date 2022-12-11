import enum


class Color(enum.Enum):
    BLACK = 30
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    PURPLE = 35
    CYAN = 36
    WHITE = 37


class BGColor(enum.Enum):
    BLACK = 40
    RED = 41
    GREEN = 42
    YELLOW = 43
    BLUE = 44
    PURPLE = 45
    CYAN = 46
    WHITE = 47


class Style(enum.Enum):
    BOLD = 1
    FAINT = 2
    ITALIC = 3
    UNDERLINE = 4
    BLINK = 5
    STRIKETHROUGH = 9


def style(*args):
    styles = ["0"]

    for a in args:
        if isinstance(a, int):
            styles.append(str(a))
        else:
            styles.append(str(a.value))

    return f"\033[{';'.join(styles)}m"


def with_style(text, *args):
    return f"{style(*args)}{text}{style()}"


def print_styled(text, *style_args):
    print(with_style(text, *style_args))


if __name__ == '__main__':
    print(with_style("test", Color.RED, BGColor.BLUE, Style.ITALIC))
    print(with_style("test", Color.RED, BGColor.BLUE, Style.UNDERLINE))
    print(with_style("test", Color.BLUE, Style.BOLD))
    print("test")

    pass
