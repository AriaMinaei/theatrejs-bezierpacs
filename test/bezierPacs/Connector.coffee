BezierPacs = require '../../src/BezierPacs'
Connector = require '../../src/bezierPacs/Connector'
Point = require '../../src/bezierPacs/Point'

makeConnector = ->

	pacs = new BezierPacs

	c = new Connector
	c._pacs = pacs
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
			c._leftTime = 100
			c._rightTime = 200

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
			c._leftTime = 100
			c._rightTime = 200

			c.activate()
			c.deactivate()

			c.changeSpy.should.have.been.calledTwice
			c.changeSpy.secondCall.should.have.been.calledWith 100, 200

	describe "_readFromLeftPoint", ->

		it "should read the props from point", ->

			c = makeConnector()

			c._rightTime = 200
			c._leftTime = 0

			left = new Point
			left.setTime 100
			left.setValue 10

			c.activate()

			c._readFromLeftPoint left

			c._leftTime.should.equal 100
			c._leftValue.should.equal 10

		it "should emit 'curve-change'", ->

			c = makeConnector()

			c.events.on 'curve-change', curveChangeSpy = sinon.spy()

			c._readFromLeftPoint new Point

			curveChangeSpy.should.have.been.calledOnce

		it "should report change", ->

			c = makeConnector()

			c._rightTime = 200
			c._leftTime = 0

			left = new Point
			left.setTime 100
			left.setValue 10

			c.activate()

			c._readFromLeftPoint left

			c.changeSpy.should.have.been.calledTwice
			c.changeSpy.secondCall.should.have.been.calledWith 0, 200

		it.skip "should not report change if not active"

	describe "_readFromRightPoint", ->

		it "should read the props from point", ->

			c = makeConnector()

			c._rightTime = 200
			c._leftTime = 0

			right = new Point
			right.setTime 100
			right.setValue 10

			c.activate()

			c._readFromRightPoint right

			c._rightTime.should.equal 100
			c._rightValue.should.equal 10

		it "should emit 'curve-change'", ->

			c = makeConnector()

			c.events.on 'curve-change', curveChangeSpy = sinon.spy()

			c._readFromRightPoint new Point

			curveChangeSpy.should.have.been.calledOnce

		it "should report change", ->

			c = makeConnector()

			c._rightTime = 200
			c._leftTime = 0

			right = new Point
			right.setTime 100
			right.setValue 10

			c.activate()

			c._readFromRightPoint right

			c.changeSpy.should.have.been.calledTwice
			c.changeSpy.secondCall.should.have.been.calledWith 0, 200

		it.skip "should not report change if not active"