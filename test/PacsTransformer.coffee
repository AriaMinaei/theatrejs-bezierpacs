PacsTransformer = require '../src/PacsTransformer'
PointsSelection = require '../src/PointsSelection'
BezierPacs = require '../src/BezierPacs'
{stringToStuff, pacsToString} = require './pacsTransformer/helpers'

require('chai').use(require 'chai-fuzzy').should()

describe "PacsTransformer", ->

	describe "constructor()", ->

		it "should work"

	describe "constructor()", ->

		it "should accept a pacs object"

	describe "general", ->

		it "should work", ->

			{pacs, selection, transformer} = stringToStuff "x y-a b-c"

			pacsToString pacs

			# console.log pacs, selection, transformer

			# t.useSelection(s)

			# t.addTransform (p) ->

			# 	p.setTime p.getTime() + 1000

	describe "setTransform()", ->

		it "should apply a transform on each point's initial state"

	describe "addTransform()", ->

		it "should apply a transform on each point's current state"

	describe "resetTransform()", ->

		it "should put all points on their initial state"