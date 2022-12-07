import colorsys
import hashlib
from collections import namedtuple
import securify.solidity.v_0_5_x.solidity_grammar as grammar

FunctionNodes = namedtuple('FunctionNodes', 'entry_node exit_node')
FunctionCallNodes = namedtuple('FunctionCallNodes', 'dispatch_node return_node')
FunctionCallDrawNodes = namedtuple('FunctionCallDrawNodes', 'dispatch_node return_node function_name')


def node_id(node):
    if any(isinstance(node, cls) for cls in [grammar.AstNode]):
        node_id_base = f'{node.node_type}{node.id}'#.encode('utf-8')
    else:
        node_id_base = hex(id(node))#
    # hash_id = hashlib.sha256(node_id_base.encode('utf-8'))
    return node_id_base # hash_id.hexdigest()


def node_color(node_id):
    hash_id = hashlib.sha256(node_id.encode('utf-8'))
    color = hash_id.hexdigest()[-6:]
    r, g, b = [int(color[i:i + 2], 16) / 256.0 for i in range(3)]
    h, _, _ = colorsys.rgb_to_hsv(r, g, b)
    s = 0.999
    v = 0.999
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    return f'#{int(r * 256):02x}{int(g * 256):02x}{int(b * 256):02x}{90:02x}'


FUNCTION_COLOR = '#3434B2'
HEADER_COLOR = '#3434B2'
ARGS_COLOR = '#ADD8E6'
GOTO_COLOR = 'blue'
CALL_COLOR = 'purple'
CONST_COLOR = '#B6FFAE'
JUMP_COLOR = 'purple'
TRUE_COLOR = '#009900'
FALSE_COLOR = 'red'
CONDITION_COLOR = '#FF9900'

COMMENT_COLOR = '#DDF8F6'

AST_CFG_COLOR = '#FF1696'

CFG_STMT_COLOR = '#1646A0'

AST_HEADER_COLOR = '#960014'
AST_HL_COLOR = '#39FF14'
