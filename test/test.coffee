chai = require 'chai'

chai.use require 'chai-fuzzy'

chai.should()

class BezierPacs

	constructor: ->

	pointToString: ->

		@getPoint()

	getPoint: ->

		@locatePoint()

	locatePoint: ->

		@findByIndex()

	getRounded: ->

		120


describe "BezierPacs", ->

	describe "pointToString()", ->

		it "should return null for a non-existing point", ->

		it "should throw if time is out of bounds", ->

		it "should serialize a single point", ->

			b = new BezierPacs

			b.pointToString(120)

		it "should throw if point is invalid", ->

		it "should not round up", ->

			(new BezierPacs).getRounded().should.equal 119.5