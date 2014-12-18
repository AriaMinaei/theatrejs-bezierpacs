BezierPacs = require '../src/BezierPacs'
Point = require '../src/bezierPacs/Point'

describe "BezierPacs", ->

	describe "constructor()", ->

		it "should work"

	describe "createPoint()", ->

		it "should return a new Point", ->

			(new BezierPacs).createPoint().should.be.instanceOf Point