import * as chai from 'chai'
import { readFileSync, readdirSync } from 'fs'
import path from 'path'
import solgraph from '../src/index.js'

chai.should()

/** Load a text file from the current directory */
const load = filename => readFileSync(path.join(__dirname, filename), 'utf-8').replace(/\r/g, '') // strip carriage returns for Windows support

/** Test that the processed input .sol file matches the output .dot file. */
const testInOut = file => {
  const name = file.slice(0, file.lastIndexOf('.'))
  const dot = solgraph(load(`in/${name}.sol`))
  dot.should.equal(load(`out/${name}.dot`))
}

describe('solgraph', () => {
  // test each .sol file in the ./test/in directory
  // against the corresponding .dot file in the ./test/out directory
  const files = readdirSync(path.join(__dirname, 'in'))
  files.forEach(file => {
    if (file.indexOf('.sol') !== -1) {
      it(file, () => testInOut(file))
    }
  })
})
