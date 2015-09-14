require('chai').use(require('sinon-chai'))

sinon = require 'sinon'

beforeEach ->
  global.document =
    createElement: sinon.stub()
    body:
      appendChild: sinon.stub()

afterEach ->
