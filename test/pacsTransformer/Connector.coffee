Connector = require '../../src/bezierPacs/Connector'
BezierPacs = require '../../src/BezierPacs'

makeConnector = ->

	pacs = new BezierPacs

	c = new Connector pacs
	pacs._reportChange = sinon.spy()
	c.changeSpy = pacs._reportChange
	c

describe "Connector", ->

	describe "constructor", ->

		it "should work", ->

			c = new Connector

	describe "isActive()", ->

		it "should not be active by default", ->

			makeConnector().isActive().should.equal no

	describe "activate()", ->

		it "should activate the connector", ->

			makeConnector().activate().isActive().should.equal yes

		it "should throw if already active", ->

			(-> makeConnector().activate().activate()).should.throw()

		it "should emit 'activation' and 'activation-state-change'", ->

			c = makeConnector()

			c.events.on 'activation', activationSpy = sinon.spy()
			c.events.on 'activation-state-change', stateChangeSpy = sinon.spy()

			c.activate()

			activationSpy.should.have.been.calledOnce
			stateChangeSpy.should.have.been.calledOnce
			stateChangeSpy.should.have.been.calledWith true

		it "should report change", ->

			c = makeConnector()
			c._setLeftTime 100
			c._setRightTime 200

			c.activate()

			c.changeSpy.should.have.been.calledOnce
			c.changeSpy.should.have.been.calledWith 100, 200

	describe "deactivate()", ->

		it "should deactivate the connector", ->

			makeConnector().activate().deactivate().isActive().should.equal no

		it "should throw if not active", ->

			(-> makeConnector().deactivate()).should.throw()

		it "should emit 'deactivation' and 'activation-state-change'", ->

			c = makeConnector()

			c.activate()

			c.events.on 'deactivation', deactivationSpy = sinon.spy()
			c.events.on 'activation-state-change', stateChangeSpy = sinon.spy()

			c.deactivate()

			deactivationSpy.should.have.been.calledOnce
			stateChangeSpy.should.have.been.calledOnce
			stateChangeSpy.should.have.been.calledWith false

		it "should report change", ->

			c = makeConnector()
			c._setLeftTime 100
			c._setRightTime 200

			c.activate()
			c.deactivate()

			c.changeSpy.should.have.been.calledTwice
			c.changeSpy.secondCall.should.have.been.calledWith 100, 200