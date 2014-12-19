{stringToStuff, pacsToString} = require './helpers'

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "_ensureInitialModelIsReady()", ->

		it "should build the initial model if it hasn't already"

	describe "_buildInitialModel()", ->

		it "should build a list of PointProxies", ->

			{transformer} = stringToStuff "a x b y c z"

			transformer._ensureInitialModelIsReady()

			transformer._proxies.list[0].point.name.should.equal 'x'
			transformer._proxies.list[1].point.name.should.equal 'y'
			transformer._proxies.list[2].point.name.should.equal 'z'

		it "should build the list in order", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			selection.clear()
			selection.addPoint selectedPoints.y
			selection.addPoint selectedPoints.x

			transformer._ensureInitialModelIsReady()
			transformer._proxies.list[0].point.name.should.equal 'x'
			transformer._proxies.list[1].point.name.should.equal 'y'

		it "should also build a map with each point's id as keys", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._proxies.map[1].point.name.should.equal 'x'
			transformer._proxies.map[2].point.name.should.equal 'y'

		it "should tell each point if it is the first or last in the list of selected points", ->

			{pacs, selection, transformer, selectedPoints} = stringToStuff "a x y"

			transformer._ensureInitialModelIsReady()

			transformer._proxies.list[0].firstSelectedPoint.should.equal yes
			transformer._proxies.list[1].firstSelectedPoint.should.equal no

			transformer._proxies.list[0].lastSelectedPoint.should.equal no
			transformer._proxies.list[1].lastSelectedPoint.should.equal yes

		it "should tell each point if it was connected to its direct unselected neighbour", ->

			{pacs, selection, transformer, selectedPoints, idOf, proxyOf} = stringToStuff "a-x y-b z-w-c-u"

			transformer._ensureInitialModelIsReady()

			expect(proxyOf('x').prevConnectedUnselectedInitialNeighbourId).to.equal 0
			expect(proxyOf('x').nextConnectedUnselectedInitialNeighbourId).to.equal null

			expect(proxyOf('y').prevConnectedUnselectedInitialNeighbourId).to.equal null
			expect(proxyOf('y').nextConnectedUnselectedInitialNeighbourId).to.equal idOf('b')

			expect(proxyOf('z').prevConnectedUnselectedInitialNeighbourId).to.equal null
			expect(proxyOf('z').nextConnectedUnselectedInitialNeighbourId).to.equal null

			expect(proxyOf('w').prevConnectedUnselectedInitialNeighbourId).to.equal null
			expect(proxyOf('w').nextConnectedUnselectedInitialNeighbourId).to.equal null

			expect(proxyOf('u').prevConnectedUnselectedInitialNeighbourId).to.equal null
			expect(proxyOf('u').nextConnectedUnselectedInitialNeighbourId).to.equal null

		it "should tell each point knows if it was initially directly or indirectly connected to its next/prev selected point", ->

			{pacs, selection, transformer, selectedPoints, proxyOf} = stringToStuff "a x-y b z-c-w u"

			transformer._ensureInitialModelIsReady()

			proxyOf('x').wasConnectedToPrevSelectedPoint.should.equal no
			proxyOf('x').wasConnectedToNextSelectedPoint.should.equal yes

			proxyOf('y').wasConnectedToPrevSelectedPoint.should.equal yes
			proxyOf('y').wasConnectedToNextSelectedPoint.should.equal no

			proxyOf('z').wasConnectedToPrevSelectedPoint.should.equal no
			proxyOf('z').wasConnectedToNextSelectedPoint.should.equal yes

			proxyOf('w').wasConnectedToPrevSelectedPoint.should.equal yes
			proxyOf('w').wasConnectedToNextSelectedPoint.should.equal no

			proxyOf('u').wasConnectedToPrevSelectedPoint.should.equal no
			proxyOf('u').wasConnectedToNextSelectedPoint.should.equal no

	describe "_ensureConfinementsAreUpToDate()", ->

		it "should recalculate each point's confinements if the confinements are invalidated"
		it "should calculate each point's confinements as its proximity to the prev/next non-selected point"

require './pacsTransformer/.transform'