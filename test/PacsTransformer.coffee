PacsTransformer = require '../src/PacsTransformer'
PointsSelection = require '../src/PointsSelection'
BezierPacs = require '../src/BezierPacs'
{stringToStuff, pacsToString} = require './pacsTransformer/helpers'
test = it

require('chai').use(require 'chai-fuzzy').should()

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should work"

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "general", ->

		it "should work", ->

			s = "x-a y-z d"

			console.log s

			{pacs, selection, transformer} = stringToStuff s

			transformer.transform (p) ->

				p.time += 100

	describe "transform()", ->

		it "should apply a transform on each point's initial state"

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