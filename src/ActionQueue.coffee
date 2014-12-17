Step = require './actionQueue/Step'
PointApplyPropsActionUnit = require './actionQueue/PointApplyPropsActionUnit'
PointDisconnectLeftActionUnit = require './actionQueue/PointDisconnectLeftActionUnit'
PointDisconnectRightActionUnit = require './actionQueue/PointDisconnectRightActionUnit'
PointGetOffSequenceActionUnit = require './actionQueue/PointGetOffSequenceActionUnit'
PointConnectRightActionUnit = require './actionQueue/PointConnectRightActionUnit'
PointGetInSequenceActionUnit = require './actionQueue/PointGetInSequenceActionUnit'


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

	rollBack: ->

		console.log '------ full rollback'

		for i in [(@_stepsOrder.length - 1)..0]

			curStepName = @_stepsOrder[i]

			step  = @_steps[curStepName]

			step.rollBack()

		console.log '----- done rollback'

		this

	rollBackTo: (name) ->

		console.log "---rollback to '#{name}'' ---"

		unless @_steps[name]?

			throw Error "No such step '#{name}'"

		for i in [(@_stepsOrder.length - 1)..0]

			curStepName = @_stepsOrder[i]

			step  = @_steps[curStepName]

			break if name is step.name

			step.rollBack()

		this

	startStep: (name) ->

		console.log 'start:', name

		if @_currentStep?

			throw Error "Already in step '#{@_currentStep.name}'"

		step = @_steps[name]

		@_currentStep = step

		step.start()

		this

	endStep: (name) ->

		console.log 'end:', name


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

			@_currentStep.addActionUnit id, actionUnit

		actionUnit

	self = this

	@_recognizedActionUnits:

		'point.applyProps': PointApplyPropsActionUnit
		'point.disconnectLeft': PointDisconnectLeftActionUnit
		'point.disconnectRight': PointDisconnectRightActionUnit
		'point.getOffSequence': PointGetOffSequenceActionUnit
		'point.connectRight': PointConnectRightActionUnit
		'point.getInSequence': PointGetInSequenceActionUnit