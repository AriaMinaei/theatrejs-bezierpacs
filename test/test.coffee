chai = require 'chai'

chai.use require 'chai-fuzzy'

chai.should()

describe "test", ->

	it "should equal 10", ->

		10.should.equal 10