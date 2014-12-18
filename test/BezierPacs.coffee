{stringToStuff, pacsToString} = require './pacsTransformer/helpers'
BezierPacs = require '../src/BezierPacs'
Point = require '../src/bezierPacs/Point'

describe "BezierPacs", ->

	describe "constructor()", ->

		it.skip "should work"

	describe "createPoint()", ->

		it "should return a new Point", ->

			(new BezierPacs).createPoint().should.be.instanceOf Point

	describe "getIndexOfItemBeforeOrAt()", ->

		it.skip "should do a binary search", ->

			stuff = stringToStuff 'a b c d'

			pacs = stuff.pacs

			pacs.getIndexOfItemBeforeOrAt(0).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(50).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(200).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(201).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(401).should.equal 2
			pacs.getIndexOfItemBeforeOrAt(601).should.equal 3
			pacs.getIndexOfItemBeforeOrAt(801).should.equal 3