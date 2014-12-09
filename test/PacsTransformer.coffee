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

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should work"

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "transform()", ->

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

			# describe "for multiple points", ->

			# 	example

			# 		from: "a  x  y"
			# 		to:   "a   x y"
			# 		fn: "+100"

		# describe "cases", ->

		# 	it "'x a' (+200) -> ' a x'", ->

		# 		{pacs, selection, transformer} = stringToStuff 'x a'

		# 		transformer.transform (p) -> p.time += 200

		# 		pacsToString(pacs).should.equal ' a x'

		# 	it "'a-x-b' (+200) -> 'a--b x'"

		# 	movement = "+200"
		# 	from = 	"a-x y-b"
		# 	to = 		"a---x b y"

		# 	movement = "scale(0.5)"
		# 	from = 	"a-x y-b"
		# 	to = 		"a--xy-b"

		# 	movement = "scale(-1)"
		# 	from = 	"a-x y-b"
		# 	to = 		"a-y x-b"

		# 	movement = "+200"
		# 	from = 	"a-x-b" # a is connected to b
		# 	to = 		"a---b x"

		# 	movement = "+200"
		# 	from = 	"a-x-y-b"
		# 	to = 		"a---x-b-y"
		# 	to = 		"a---x b y"

		# 	movement = "+200"
		# 	from = 	"x--y a"
		# 	to = 		"   x-a-y"

		# 	from = 	"a x-y b"
		# 	to = 		"a     b x-y"

		# 	from = 	"a x--y b"
		# 	to = 		"a    x-b-y"

		# 	from = 	"a x---y b c"
		# 	to = 		"a     x-b c-y"

		# 	"a-x b"
		# 	"a   b x"

		# 	"   a-x b"
		# 	" x a   b"






	describe "_ensureInitialModelIsReady()", ->

		it "should build it the initial model if it's is not ready"

	describe "_buildInitialModel()", ->

		it "should build a list of TransformablePoint-s"
		it "should build the list in order"
		it "should also build a map with each point's _idInPacs as keys"
		it "should tell each point if it is the first or last in the list of selected points"
		it "should tell each point knows if it was initially connected to its next/prev selected point"

	describe "_ensureConfinementsAreUpToDate()", ->

		it "should recalculate each point's confinements if the confinements are invalidated"
		it "should calculate each point's confinements as its proximity to the prev/next non-selected point"