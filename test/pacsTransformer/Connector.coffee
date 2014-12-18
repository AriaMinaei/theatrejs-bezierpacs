Connector = require '../../src/bezierPacs/Connector'

describe "Connector", ->

	describe "constructor", ->

		it "should work", ->

			c = new Connector

	describe "isActive()", ->

		it "should not be active by default", ->

			(new Connector).isActive().should.equal no

	describe "activate()", ->

		it "should activate the connector", ->

			(new Connector).activate().isActive().should.equal yes

		it "should throw if already active", ->

			(-> (new Connector).activate().activate()).should.throw()

		it.skip "should emit 'activation'"

	describe "deactivate()", ->

		it "should deactivate the connector", ->

			(new Connector).activate().deactivate().isActive().should.equal no

		it "should throw if not active", ->

			(-> (new Connector).deactivate()).should.throw()

		it.skip "should emit 'activation'"