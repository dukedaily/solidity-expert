import { Graph } from 'graphlib'
import * as dot from 'graphlib-dot'

const solparser = require('@solidity-parser/parser')

const DEPRECATED = ['send', 'transfer']

const DEPRECATED_NODE_STYLE = { shape: 'rectangle' }
const EVENT_NODE_STYLE = { shape: 'hexagon' }

const COLORS = {
  CONSTANT: 'blue',
  CALL: 'orange',
  INTERNAL: 'gray',
  VIEW: 'yellow',
  PURE: 'green',
  PAYABLE: 'brown',
  DEPRECATED: 'red',
}

/** Returns the value of a given property name. */
const prop = name => object => object[name]

/** Returns true if an object contains a given property value. If an array of values are passed, returns true if any of them are in the property value. */
const propEquals = (name, values) => object =>
  Array.isArray(values) ? values.includes(object[name]) : object[name] === values

/** Finds all call expression nodes in an AST. */
const callees = node => {
  if (!(node.body && node.body.statements)) return []
  const { statements } = node.body
  return statements.filter(
    statement =>
      statement.type === 'EmitStatement' ||
      (statement.type === 'ExpressionStatement' &&
        statement.expression.type === 'FunctionCall' &&
        !['require', 'assert'].includes(statement.expression.expression.name)),
  )
}

/** Determines the name of the graph node to render from the AST node. */
const graphNodeName = node =>
  node.name ||
  (node.isConstructor ? 'constructor' : node.isFallback ? 'fallback' : node.isReceiveEther ? 'receive' : 'UNKNOWN')

/** Main entry point to generate a DOT graph from solidity code. */
const solgraph = source => {
  // parse the Solidity source
  let ast
  try {
    ast = solparser.parse(source)
  } catch (e) {
    console.error('Parse error. Please report to https://github.com/sc-forks/solidity-parser.')
    console.error(e)
    process.exit(1)
  }

  // get a list of all function nodes
  const contracts = ast.children.filter(child => child.type === 'ContractDefinition')
  const functionAndEventNodes = contracts
    .map(contract => contract.subNodes)
    .flat()
    .filter(propEquals('type', ['FunctionDefinition', 'EventDefinition']))

  // analyze the security of the functions
  const analyzedNodes = functionAndEventNodes.map(node => {
    const functionCallees = callees(node).map(statement => {
      switch (statement.type) {
        case 'EmitStatement': {
          return statement.eventCall.expression.name
        }
        case 'ExpressionStatement': {
          const expression = statement.expression.expression
          return expression.name || (expression.type === 'MemberAccess' ? expression.memberName : null)
        }
        default: {
          throw new Error(`Unexpected statement type (${statement.type}) in analyzed nodes.`)
        }
      }
    })

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
      event: node.type && node.type === 'EventDefinition',
    }
  })

  // generate a graph
  const digraph = new Graph()
  analyzedNodes.forEach(({ name, callees, send, constant, internal, view, pure, transfer, payable, event }) => {
    // node
    digraph.setNode(
      name,
      event
        ? EVENT_NODE_STYLE
        : send
        ? { color: COLORS.DEPRECATED }
        : constant
        ? { color: COLORS.CONSTANT }
        : internal
        ? { color: COLORS.INTERNAL }
        : view
        ? { color: COLORS.VIEW }
        : pure
        ? { color: COLORS.PURE }
        : transfer
        ? { color: COLORS.DEPRECATED }
        : payable
        ? { color: COLORS.PAYABLE }
        : {},
    )

    // edge
    callees.forEach(callee => {
      const calleeNodeName = DEPRECATED.includes(callee) ? `DEPRECATED(${callee})` : callee
      digraph.setEdge(name, calleeNodeName)
    })
  })

  // add deprecated native calls
  DEPRECATED.forEach(name => {
    if (analyzedNodes.some(prop(name))) {
      digraph.setNode(`DEPRECATED(${name})`, DEPRECATED_NODE_STYLE)
    }
  })

  return dot.write(digraph)
}

export default solgraph
