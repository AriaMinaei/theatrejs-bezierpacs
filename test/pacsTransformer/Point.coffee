BezierPacs = require '../../src/BezierPacs'
Point = require '../../src/bezierPacs/Point'

describe "Point", ->

	describe "constructor()", ->

		it "should work", ->

			(new BezierPacs).createPoint()

	describe "belongTo()", ->

		it "point should not have an id before calling belongTo()", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			expect(p._id).to.equal null

		it "point should get an id after calling belongTo()", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			expect(p._id).to.not.equal null

		it "should get the point owned by a pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p._pacs.should.equal pacs

		it "should throw if the point already belongs to a pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			(-> p.belongTo pacs).should.throw()

	describe "disbelong()", ->

		it "should get the point disowned by the pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			p.belongTo pacs

			p.disbelong()

			expect(p._pacs).to.equal null

		it "should not make the point lose its id", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			p.belongTo pacs

			id = p._id

			p.disbelong

			p._id.should.equal id

		it "should throw if the point doesn't belong to any pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			(-> p.disbelong()).should.throw()

		it "should throw if the point is already inserted in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			(-> p.disbelong()).should.throw()

	describe "insert()", ->

		it "should get the point inserted the point in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			p._list.should.equal pacs._list
			p._sequence.should.equal pacs._list._pointsInSequence
			pacs._list._pointsInSequence[0].should.equal p

		it "should throw if the point isn't owned by any pacs yet", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			(-> p.insert()).should.throw()

		it "should throw if the point is already inserted", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			(-> p.insert()).should.throw()

	describe "_getInsertedInSequence()", ->

		it "should properly link to next/prev points", ->

			pacs = new BezierPacs

			points = []

			for i in [0..2]

				points.push pacs.createPoint().belongTo(pacs).setTime(i * 100).insert()

			expect(points[0]._leftPoint).to.equal null
			expect(points[0]._rightPoint).to.equal points[1]

			expect(points[1]._leftPoint).to.equal points[0]
			expect(points[1]._rightPoint).to.equal points[2]

			expect(points[2]._leftPoint).to.equal points[1]
			expect(points[2]._rightPoint).to.equal null

		it.skip "should throw if it gets in between a connection"

	describe "remove()", ->

		it "should get the point removed from the sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			p.remove()

			expect(p._sequence).to.equal null
			pacs._list._pointsInSequence.should.not.contain p

		it "should throw if the point is not in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			(-> p.remove()).should.throw()

	describe "_getRemovedFromSequence()", ->

		it.skip "should throw if the point is connected", ->