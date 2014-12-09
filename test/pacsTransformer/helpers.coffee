PacsTransformer = require '../../src/PacsTransformer'
PointsSelection = require '../../src/PointsSelection'
BezierPacs = require '../../src/BezierPacs'

module.exports.stringToStuff = stringToStuff = (strTimeline) ->

	stuff = {}

	pacs = stuff.pacs = new BezierPacs
	selection = stuff.selection = new PointsSelection pacs
	transformer = stuff.transformer = new PacsTransformer pacs
	allPoints = stuff.allPoints = {}
	selectedPoints = stuff.selectedPoints = {}
	unselectedPoints = stuff.unselectedPoints = {}
	listOfAllPoints = stuff.listOfAllPoints = []

	transformer.useSelection selection

	curTime = 0
	lastConnector = null
	for char in strTimeline

		if char is ' '

			curTime += 100

			continue

		if char is '-'

			unless lastConnector?

				lastConnector = pacs.createConnector()
				.setTime(curTime)
				.getRecognizedBy pacs

			curTime += 100

			continue

		if char.match /[a-z]{1}/

			name = char

			point = pacs.createPoint()
			.setTime curTime
			.getRecognizedBy pacs
			.getInSequence()

			point.name = name

			listOfAllPoints.push point
			allPoints[name] = point

			if name.match /[a-o]{1}/

				unselectedPoints[name] = point

			else if name.match /[t-z]{1}/

				selectedPoints[name] = point

				selection.addPoint point

			if lastConnector?

				lastConnector.getInSequence()
				lastConnector = null

	stuff

module.exports.pacsToString = pacsToString = (pacs) ->

	sequence = pacs._itemsInSequence

	str = ''
	curTime = 0
	inConnection = no

	for item in sequence

		if item.isPoint()

			if curTime isnt item._time

				stringToRepeat = if inConnection then '-' else ' '

				for i in [0...((item._time - curTime) / 100)]

					str += stringToRepeat

				curTime = item._time

				if inConnection then inConnection = no

			if item.name?

				str += item.name

			else

				str += '*'

				curTime += 100

		else

			inConnection = yes

	str

describe "PacsTransformer Helpers", ->

	describe "stringToStuff()", ->

		it "should accept a string like 'a  x-b-y c'"
		it "should return an object called `stuff` that has pacs, selection, transformer, and a list of all the points created"

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