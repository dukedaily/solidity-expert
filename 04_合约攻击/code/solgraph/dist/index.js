"use strict";

function _typeof(obj) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (obj) { return typeof obj; } : function (obj) { return obj && "function" == typeof Symbol && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }, _typeof(obj); }
Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = void 0;
var _graphlib = require("graphlib");
var dot = _interopRequireWildcard(require("graphlib-dot"));
function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function _getRequireWildcardCache(nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }
function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || _typeof(obj) !== "object" && typeof obj !== "function") { return { "default": obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj["default"] = obj; if (cache) { cache.set(obj, newObj); } return newObj; }
var solparser = require('@solidity-parser/parser');
var DEPRECATED = ['send', 'transfer'];
var DEPRECATED_NODE_STYLE = {
  shape: 'rectangle'
};
var EVENT_NODE_STYLE = {
  shape: 'hexagon'
};
var COLORS = {
  CONSTANT: 'blue',
  CALL: 'orange',
  INTERNAL: 'gray',
  VIEW: 'yellow',
  PURE: 'green',
  PAYABLE: 'brown',
  DEPRECATED: 'red'
};

/** Returns the value of a given property name. */
var prop = function prop(name) {
  return function (object) {
    return object[name];
  };
};

/** Returns true if an object contains a given property value. If an array of values are passed, returns true if any of them are in the property value. */
var propEquals = function propEquals(name, values) {
  return function (object) {
    return Array.isArray(values) ? values.includes(object[name]) : object[name] === values;
  };
};

/** Finds all call expression nodes in an AST. */
var callees = function callees(node) {
  if (!(node.body && node.body.statements)) return [];
  var statements = node.body.statements;
  return statements.filter(function (statement) {
    return statement.type === 'EmitStatement' || statement.type === 'ExpressionStatement' && statement.expression.type === 'FunctionCall' && !['require', 'assert'].includes(statement.expression.expression.name);
  });
};

/** Determines the name of the graph node to render from the AST node. */
var graphNodeName = function graphNodeName(node) {
  return node.name || (node.isConstructor ? 'constructor' : node.isFallback ? 'fallback' : node.isReceiveEther ? 'receive' : 'UNKNOWN');
};

/** Main entry point to generate a DOT graph from solidity code. */
var solgraph = function solgraph(source) {
  // parse the Solidity source
  var ast;
  try {
    ast = solparser.parse(source);
  } catch (e) {
    console.error('Parse error. Please report to https://github.com/sc-forks/solidity-parser.');
    console.error(e);
    process.exit(1);
  }

  // get a list of all function nodes
  var contracts = ast.children.filter(function (child) {
    return child.type === 'ContractDefinition';
  });
  var functionAndEventNodes = contracts.map(function (contract) {
    return contract.subNodes;
  }).flat().filter(propEquals('type', ['FunctionDefinition', 'EventDefinition']));

  // analyze the security of the functions
  var analyzedNodes = functionAndEventNodes.map(function (node) {
    var functionCallees = callees(node).map(function (statement) {
      switch (statement.type) {
        case 'EmitStatement':
          {
            return statement.eventCall.expression.name;
          }
        case 'ExpressionStatement':
          {
            var expression = statement.expression.expression;
            return expression.name || (expression.type === 'MemberAccess' ? expression.memberName : null);
          }
        default:
          {
            throw new Error("Unexpected statement type (".concat(statement.type, ") in analyzed nodes."));
          }
      }
    });
    return {
      name: graphNodeName(node),
      callees: functionCallees,
      send: functionCallees.includes('send'),
      transfer: functionCallees.includes('transfer'),
      constant: node.stateMutability && node.stateMutability === 'constant',
      internal: node.visibility && node.visibility === 'internal',
      view: node.stateMutability && node.stateMutability === 'view',
      pure: node.stateMutability && node.stateMutability === 'pure',
      payable: node.stateMutability && node.stateMutability === 'payable',
      event: node.type && node.type === 'EventDefinition'
    };
  });

  // generate a graph
  var digraph = new _graphlib.Graph();
  analyzedNodes.forEach(function (_ref) {
    var name = _ref.name,
      callees = _ref.callees,
      send = _ref.send,
      constant = _ref.constant,
      internal = _ref.internal,
      view = _ref.view,
      pure = _ref.pure,
      transfer = _ref.transfer,
      payable = _ref.payable,
      event = _ref.event;
    // node
    digraph.setNode(name, event ? EVENT_NODE_STYLE : send ? {
      color: COLORS.DEPRECATED
    } : constant ? {
      color: COLORS.CONSTANT
    } : internal ? {
      color: COLORS.INTERNAL
    } : view ? {
      color: COLORS.VIEW
    } : pure ? {
      color: COLORS.PURE
    } : transfer ? {
      color: COLORS.DEPRECATED
    } : payable ? {
      color: COLORS.PAYABLE
    } : {});

    // edge
    callees.forEach(function (callee) {
      var calleeNodeName = DEPRECATED.includes(callee) ? "DEPRECATED(".concat(callee, ")") : callee;
      digraph.setEdge(name, calleeNodeName);
    });
  });

  // add deprecated native calls
  DEPRECATED.forEach(function (name) {
    if (analyzedNodes.some(prop(name))) {
      digraph.setNode("DEPRECATED(".concat(name, ")"), DEPRECATED_NODE_STYLE);
    }
  });
  return dot.write(digraph);
};
var _default = solgraph;
exports["default"] = _default;