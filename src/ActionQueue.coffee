Step = require './actionQueue/Step'
PointApplyPropsActionUnit = require './actionQueue/PointApplyPropsActionUnit'
PointDisconnectLeftActionUnit = require './actionQueue/PointDisconnectLeftActionUnit'
PointDisconnectRightActionUnit = require './actionQueue/PointDisconnectRightActionUnit'
PointGetOffSequenceActionUnit = require './actionQueue/PointGetOffSequenceActionUnit'
PointConnectRightActionUnit = require './actionQueue/PointConnectRightActionUnit'


module.exports = class ActionQueue

	constructor: (@_stepsOrder) ->

		@_steps = {}

		for name in @_stepsOrder

			@_steps[name] = new Step this, name

		@_currentStep = null

	haveTakenStep: (name) ->

		@_stepsTaken[name]?

	haveTakenStepsBefore: (targetStepName) ->

		for name, step of @_steps

			return yes if step.haveBeenTaken()

			break if name is targetStepName

		no

	rollBackTo: ->

	startStep: (name) ->

		if @_currentStep?

			throw Error "Already in step '#{@_currentStep.name}'"

		step = @_steps[name]

		@_currentStep = step

		step.start()

		this

	endStep: (name) ->

		unless @_currentStep?

			throw Error "No step has been started"

		if @_currentStep.name isnt name

			throw Error "'#{name}' is not the active step. '#{@_currentStep.name}' is"

		@_currentStep.end()

		@_currentStep = null

		this

	getActionUnitFor: (actionUnitName, mainObject, props) ->

		unless @_currentStep?

			throw Error "No step is active"

		actionUnitClass = self._recognizedActionUnits[actionUnitName]

		unless actionUnitClass?

			throw Error "Unkown action unit name '#{actionUnitName}'"

		id = actionUnitClass.getIdFor mainObject, props

		if @_currentStep.hasActionUnit id

			actionUnit = @_currentStep.getActionUnit id

			actionUnit._setActionUnitProps props

		else

			actionUnit = new actionUnitClass this, mainObject, props

			@_currentStep.addActionUnit actionUnit

		actionUnit

	self = this

	@_recognizedActionUnits:

		'point.applyProps': PointApplyPropsActionUnit
		'point.disconnectLeft': PointDisconnectLeftActionUnit
		'point.disconnectRight': PointDisconnectRightActionUnit
		'point.getOffSequence': PointGetOffSequenceActionUnit
		'point.connectRight': PointConnectRightActionUnit