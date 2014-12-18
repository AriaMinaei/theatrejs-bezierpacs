{stringToStuff, pacsToString} = require './pacsTransformer/helpers'

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "_ensureInitialModelIsReady()", ->

		it "should build the initial model if it hasn't already"

	describe "_buildInitialModel()", ->

		it.skip "should build a list of TransformablePoint-s", ->

			{pacs, selection, transformer} = stringToStuff "a x b y c z"

			transformer._ensureInitialModelIsReady()

			transformer._pointsArray[0].initialPoint.name.should.equal 'x'
			transformer._pointsArray[1].initialPoint.name.should.equal 'y'
			transformer._pointsArray[2].initialPoint.name.should.equal 'z'

		it.skip "should build the list in order", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			selection.clear()
			selection.addPoint selectedPoints.y
			selection.addPoint selectedPoints.x

			transformer._ensureInitialModelIsReady()
			transformer._pointsArray[0].initialPoint.name.should.equal 'x'
			transformer._pointsArray[1].initialPoint.name.should.equal 'y'

		it.skip "should also build a map with each point's id as keys", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._pointsMap[1].initialPoint.name.should.equal 'x'
			transformer._pointsMap[2].initialPoint.name.should.equal 'y'

		it.skip "should tell each point if it is the first or last in the list of selected points", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._pointsArray[0].firstSelectedPoint.should.equal yes
			transformer._pointsArray[1].firstSelectedPoint.should.equal no

			transformer._pointsArray[0].lastSelectedPoint.should.equal no
			transformer._pointsArray[1].lastSelectedPoint.should.equal yes

		it.skip "should tell each point if it was connected to its direct unselected neighbour", ->

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

		it.skip "should tell each point knows if it was initially directly or indirectly connected to its next/prev selected point", ->

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

require './pacsTransformer/.transform'