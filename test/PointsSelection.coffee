PointsSelection = require '../src/PointsSelection'
BezierPacs = require '../src/BezierPacs'

describe "PointsSelection", ->
	describe "constructor()", ->
		it "should accept a pacs object"

	describe "addPoint()", ->
		it "should only accept a Point"
		it "should do nothing if the point is already in the list"
		it "should only accept a point that is in the current BezierPacs"
		it "should add the point to the list if it doesn't already exist"
		it "should emit 'new-point' if the point is added"

	describe "addPoints()", ->
		it "should accept an array of Point-s"

	describe "removePoint()", ->
		it "should do nothing if the point doesn't exist in the list"
		it "should remove the point from the list if it is already in the list"
		it "should emit 'remove-point' when pushing a point out of the list"

	describe "removePoints()", ->
		it "should accept an array of Point-s"

	describe "clear()", ->
		it "should remove all the points from the list"
		it "should emit 'remove-point' for each point"

	describe "getPoints()", ->
		it "should return the array of points in this selection"