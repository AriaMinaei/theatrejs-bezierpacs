PacsTransformer = require '../src/PacsTransformer'
PointsSelection = require '../src/PointsSelection'
BezierPacs = require '../src/BezierPacs'

module.exports.stringToStuff = stringToStuff = (strTimeline) ->

	stuff = {}

	pacs = stuff.pacs = new BezierPacs
	selection = stuff.selection = new PointsSelection pacs
	transformer = stuff.transformer = new PacsTransformer pacs
	allPoints = stuff.allPoints = {}
	selectedPoints = stuff.selectedPoints = {}
	unselectedPoints = stuff.unselectedPoints = {}
	listOfAllPoints = stuff.listOfAllPoints = []

	idOf = stuff.idOf = (name) -> allPoints[name]._id

	stuff.proxyOf = (name) ->

		transformer._ensureInitialModelIsReady()

		transformer._proxies.map[idOf(name)]

	transformer.useSelection selection

	curTime = 0
	shouldConnectNextPointToLeft = no

	for char in strTimeline

		if char is ' '

			curTime += 100

			continue

		if char is '-'

			shouldConnectNextPointToLeft = yes

			curTime += 100

			continue

		if char.match /[a-z]{1}/

			name = char

			point = pacs.createPoint()
			.setTime curTime
			.belongTo pacs
			.insert()

			if shouldConnectNextPointToLeft

				point.connectToLeft()

				shouldConnectNextPointToLeft = no

			point.name = name

			listOfAllPoints.push point
			allPoints[name] = point

			if name.match /[a-o]{1}/

				unselectedPoints[name] = point

			else if name.match /[t-z]{1}/

				selectedPoints[name] = point

				selection.addPoint point

			curTime += 100

	stuff

module.exports.pacsToString = pacsToString = (pacs) ->

	sequence = pacs._list._pointsInSequence

	str = ''
	curTime = 0

	for point in sequence

		if curTime isnt point._time

			stringToRepeat = if point.isConnectedToLeft() then '-' else ' '

			for i in [0...((point._time - curTime) / 100)]

				str += stringToRepeat

			curTime = point._time

		if point.name?

			str += point.name

		else

			str += '*'

		curTime += 100

	str

describe "PacsTransformer Helpers", ->

	describe "stringToStuff()", ->

		it "should accept a string like 'a  x-b-y c'"
		it "should return an object called `stuff` that has pacs, selection, transformer, and a list of all the points created"

		it "case: a b c-d e--f", ->

			{unselectedPoints} = stringToStuff "a b c-d e--f"

			unselectedPoints.a._time.should.equal 0
			unselectedPoints.b._time.should.equal 200
			unselectedPoints.c._time.should.equal 400
			unselectedPoints.d._time.should.equal 600
			unselectedPoints.e._time.should.equal 800
			unselectedPoints.f._time.should.equal 1100
			unselectedPoints.f.isConnectedToLeft().should.equal yes

	describe "pacsToString()", ->

		it "should accept a BezierPacs object and create a string from reading its sequence"

	describe "these cases are pacs built and then unbuilt from a string", ->

		checkCombo = (str) ->

			it "string: '#{str}'", ->

				stuff = stringToStuff str

				newString = pacsToString stuff.pacs

				str.should.equal newString

		checkCombo ''
		checkCombo 'x'
		checkCombo 'a'
		checkCombo 'ab'
		checkCombo 'a b'
		checkCombo 'a b c'
		checkCombo 'a b-c'
		checkCombo 'a b--c'
		checkCombo 'a b-x-c'
		checkCombo 'a-b c x--y--d'

	describe "idOf()", ->

		it "should return the correct id of each point", ->

			{idOf} = stringToStuff 'a x-y b'

			idOf('a').should.equal 0
			idOf('x').should.equal 1
			idOf('y').should.equal 2
			idOf('b').should.equal 3

	describe "proxyOf()", ->

		it "should return the proxy of each point", ->

			{proxyOf} = stringToStuff 'a x-y b'

			proxyOf('x').point._id.should.equal 1
			proxyOf('y').point._id.should.equal 2