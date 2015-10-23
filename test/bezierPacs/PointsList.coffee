{stringToStuff, pacsToString} = require '../helpers'

describe "PointsList", ->
	describe "getIndexOfItemBeforeOrAt()", ->
		it "should do a binary search", ->
			stuff = stringToStuff 'a b c d'
			list = stuff.pacs._list

			list.getIndexOfPointBeforeOrAt(0).should.equal 0
			list.getIndexOfPointBeforeOrAt(50).should.equal 0
			list.getIndexOfPointBeforeOrAt(200).should.equal 1
			list.getIndexOfPointBeforeOrAt(201).should.equal 1
			list.getIndexOfPointBeforeOrAt(401).should.equal 2
			list.getIndexOfPointBeforeOrAt(601).should.equal 3
			list.getIndexOfPointBeforeOrAt(801).should.equal 3