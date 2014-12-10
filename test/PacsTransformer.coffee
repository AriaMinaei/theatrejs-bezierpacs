PacsTransformer = require '../src/PacsTransformer'
PointsSelection = require '../src/PointsSelection'
BezierPacs = require '../src/BezierPacs'
{stringToStuff, pacsToString} = require './pacsTransformer/helpers'

example = (opts) ->

	{from, to, fn} = opts

	if matches = fn.match /^\+([0-9]+)$/

		func = (p) -> p.time += parseInt matches[1]

	else if matches = fn.match /^\-([0-9]+)$/

		func = (p) -> p.time -= parseInt matches[1]

	it "Example: '#{from}' > [#{fn}] -> '#{to}'", ->

		{pacs, transformer} = stringToStuff from
		transformer.transform func
		to.should.equal pacsToString pacs

require('chai').use(require 'chai-fuzzy').should()
expect = require('chai').expect

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should work"

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "transform()", ->

		example

			from: "a  x y-b-c-z  b"
			to:   "a   x y-b-c-z b"
			fn: "+100"

		return

		it "should apply a transform on each point's initial state"

		describe "when points are moving inside their confinements", ->

			describe "for single points", ->

				describe "if the point is not connected to an unselected point, we should just update its props.", ->

					example

						from: "a  x  b"
						to:   "a   x b"
						fn: "+100"

					example

						from: "a  x  b"
						to:   "a x   b"
						fn: "-100"

					example

						from: "a  x  b y"
						to:   "a   x b  y"
						fn: "+100"

					example

						from: "a  x  b y  c"
						to:   "a   x b  y c"
						fn: "+100"

				describe "if the point is connected to unselected points, we should keep the connections.", ->

					example

						from: "a--x--b"
						to:   "a---x-b"
						fn: "+100"

					example

						from: "a--x--b"
						to:   "a-x---b"
						fn: "-100"

					example

						from: "a--x--b-y"
						to:   "a---x-b--y"
						fn: "+100"

					example

						from: "a--x--b-y  c"
						to:   "a---x-b--y c"
						fn: "+100"

					example

						from: "a--x--b-y--c"
						to:   "a---x-b--y-c"
						fn: "+100"

			describe "for multiple points", ->

				describe "we should preserve internal connections.", ->

					example

						from: "a  x y  b"
						to:   "a   x y b"
						fn: "+100"

					example

						from: "a  x-y  b"
						to:   "a   x-y b"
						fn: "+100"

				describe "we should preserve connections from selected points to unselected points", ->

					example

						from: "a--x y--b"
						to:   "a---x y-b"
						fn: "+100"

					example

						from: "a--x-y--b"
						to:   "a---x-y-b"
						fn: "+100"

					example

						from: "a--x-y--b-z-w"
						to:   "a---x-y-b--z-w"
						fn: "+100"

		describe "when points are moving out of their confinements", ->

			# Alright, so, we don't know exactly how pacs should behaved if a bunch
			# of points are selected and moved around. So for now, we'll just go with
			# these simple rules, until we can play with the interface and see if these
			# rules make sense.
			#
			#  * We'll keep continuous connections among external points alive
			#  * We'll keep continous connections among internal points alive
			#  * We'll keep the in-confinement rules alive when applicable

			describe "for single points", ->

				example

					from: "a x b"
					to:   "a   b x"
					fn: "+200"

				example

					from: "a-x b"
					to:   "a   b x"
					fn: "+200"

				example

					from: "a   b-x"
					to:   "a x b"
					fn: "-200"

				example

					from: "a-x-b"
					to:   "a---b x"
					fn: "+200"


	describe "_ensureInitialModelIsReady()", ->

		it "should build it the initial model if it's is not ready"

	describe "_buildInitialModel()", ->

		it "should build a list of TransformablePoint-s", ->

			{pacs, selection, transformer} = stringToStuff "a x b y c z"

			transformer._ensureInitialModelIsReady()

			transformer._pointsArray[0].initialPoint.name.should.equal 'x'
			transformer._pointsArray[1].initialPoint.name.should.equal 'y'
			transformer._pointsArray[2].initialPoint.name.should.equal 'z'

		it "should build the list in order", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			selection.clear()
			selection.addPoint selectedPoints.y
			selection.addPoint selectedPoints.x

			transformer._ensureInitialModelIsReady()
			transformer._pointsArray[0].initialPoint.name.should.equal 'x'
			transformer._pointsArray[1].initialPoint.name.should.equal 'y'

		it "should also build a map with each point's _idInPacs as keys", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._pointsMap[1].initialPoint.name.should.equal 'x'
			transformer._pointsMap[2].initialPoint.name.should.equal 'y'

		it "should tell each point if it is the first or last in the list of selected points", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._pointsArray[0].firstSelectedPoint.should.equal yes
			transformer._pointsArray[1].firstSelectedPoint.should.equal no

			transformer._pointsArray[0].lastSelectedPoint.should.equal no
			transformer._pointsArray[1].lastSelectedPoint.should.equal yes

		it "should tell each point if it was connected to its direct unselected neighbour", ->

			{pacs, selection, transformer, selectedPoints, idOf, transformablePoint} = stringToStuff "a-x y-b z-w-c-u"

			transformer._ensureInitialModelIsReady()

			expect(transformablePoint('x').prevConnectedUnselectedNeighbour).to.equal idOf('a')
			expect(transformablePoint('x').nextConnectedUnselectedNeighbour).to.equal null

			expect(transformablePoint('y').prevConnectedUnselectedNeighbour).to.equal null
			expect(transformablePoint('y').nextConnectedUnselectedNeighbour).to.equal idOf('b')

			expect(transformablePoint('z').prevConnectedUnselectedNeighbour).to.equal null
			expect(transformablePoint('z').nextConnectedUnselectedNeighbour).to.equal null

			expect(transformablePoint('w').prevConnectedUnselectedNeighbour).to.equal null
			expect(transformablePoint('w').nextConnectedUnselectedNeighbour).to.equal null

			expect(transformablePoint('u').prevConnectedUnselectedNeighbour).to.equal null
			expect(transformablePoint('u').nextConnectedUnselectedNeighbour).to.equal null

		it "should tell each point knows if it was initially directly or indirectly connected to its next/prev selected point", ->

			{pacs, selection, transformer, selectedPoints, transformablePoint} = stringToStuff "a x-y b z-c-w u"

			transformer._ensureInitialModelIsReady()

			transformablePoint('x').wasConnectedToPrevSelectedPoint.should.equal no
			transformablePoint('x').wasConnectedToNextSelectedPoint.should.equal yes

			transformablePoint('y').wasConnectedToPrevSelectedPoint.should.equal yes
			transformablePoint('y').wasConnectedToNextSelectedPoint.should.equal no

			transformablePoint('z').wasConnectedToPrevSelectedPoint.should.equal no
			transformablePoint('z').wasConnectedToNextSelectedPoint.should.equal yes

			transformablePoint('w').wasConnectedToPrevSelectedPoint.should.equal yes
			transformablePoint('w').wasConnectedToNextSelectedPoint.should.equal no

			transformablePoint('u').wasConnectedToPrevSelectedPoint.should.equal no
			transformablePoint('u').wasConnectedToNextSelectedPoint.should.equal no

	describe "_ensureConfinementsAreUpToDate()", ->

		it "should recalculate each point's confinements if the confinements are invalidated"
		it "should calculate each point's confinements as its proximity to the prev/next non-selected point"