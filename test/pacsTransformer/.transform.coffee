{stringToStuff, pacsToString} = require '../helpers'
example = (opts, funcType) ->

	{from, to, fn} = opts

	if matches = fn.match /^\+([0-9]+)$/

		func = (p) -> p.time += parseInt matches[1]

	else if matches = fn.match /^\-([0-9]+)$/

		func = (p) -> p.time -= parseInt matches[1]

	testFunc = if funcType is 'skip' then it.skip else if funcType is 'only' then it.only else it

	testFunc "Example: '#{from}' > [#{fn}] -> '#{to}'", ->

		{pacs, transformer} = stringToStuff from
		transformer.transform func
		to.should.equal pacsToString pacs
		# transformer.transform (p) ->
		# from.should.equal pacsToString pacs

_example = (opts) -> example opts, 'skip'
_exampleOnly = (opts) -> example opts, 'only'

describe "PacsTransformer", ->

	return

	describe "transform()", ->

		it "should apply a transform on each point's initial state"

		describe "for points moving in confinement", ->

			describe "for single points", ->

				describe "if the point is not connected to an unselected point, we should just update its props.", ->

					example

						from: "a  x  b"
						to:   "a   x b"
						fn: "+100"

					example

						from: "a  x  b"
						to:   "a x   b"
						fn: "-100"

					example

						from: "a  x  b y"
						to:   "a   x b  y"
						fn: "+100"

					example

						from: "a  x  b y  c"
						to:   "a   x b  y c"
						fn: "+100"

				describe "if the point is connected to unselected points, we should keep the connections.", ->

					example

						from: "a--x--b"
						to:   "a---x-b"
						fn: "+100"

					example

						from: "a--x--b"
						to:   "a-x---b"
						fn: "-100"

					example

						from: "a--x--b-y"
						to:   "a---x-b--y"
						fn: "+100"

					example

						from: "a--x--b-y  c"
						to:   "a---x-b--y c"
						fn: "+100"

					example

						from: "a--x--b-y--c"
						to:   "a---x-b--y-c"
						fn: "+100"

			describe "for multiple points", ->

				describe "we should preserve internal connections.", ->

					example

						from: "a  x y  b"
						to:   "a   x y b"
						fn: "+100"

					example

						from: "a  x-y  b"
						to:   "a   x-y b"
						fn: "+100"

				describe "we should preserve connections from selected points to unselected points", ->

					example

						from: "a--x y--b"
						to:   "a---x y-b"
						fn: "+100"

					example

						from: "a--x-y--b"
						to:   "a---x-y-b"
						fn: "+100"

					example

						from: "a--x-y--b-z-w"
						to:   "a---x-y-b--z-w"
						fn: "+100"

		describe "for points moving out of confinement", ->

			# Alright, so, we don't know exactly how pacs should behaved if a bunch
			# of points are selected and moved around. So for now, we'll just go with
			# these simple rules, until we can play with the interface and see if these
			# rules make sense.
			#
			#  * We'll keep continuous connections among external points alive
			#  * We'll keep continous connections among internal points alive
			#  * We'll keep the in-confinement rules alive when applicable

			describe "should try to keep external to extenral connections alive", ->

				describe "should preserve external to external connections interjected by existing selected points", ->

					example

						from: "a-x-b"
						to:   "a--b x"
						fn: "+200"

					_example

						from: "a-x-y-b"
						to:   "a-----b x-y"
						fn: "+300"

					_example

						from: "f a-x-b-y-c      d-e"
						to:   "f a---b---c x--y d-e"
						fn: "+600"

				_example

					from: "a x b---c"
					to:   "a   b-x-c"
					fn: "+200"

				_example

					from: "a x b-y-c"
					to:   "a   b-x-c y"
					fn: "+200"

				_example

					from: "a x b-y-z-c"
					to:   "a   b--x--c y-z"
					fn: "+400"

			describe "should try to keep internal to internal connections alive", ->

				_example

					from: "a x---y b"
					to:   "a    x--b-y"
					fn: "+300"

				# So far, the procedure is:
				# * dcInternalToExternalConnections
				# * dcInternalConnections
				# * getOffSequence
				# * remakeExternalConnections
				# * applyProps
				# * dcExternalConnectionsToBeInterjected
				# * getInSequence
				# * remakeInterjectedExternalConnections
				# * remakeInternalConnections

				_example

					from: "a x-----y b c"
					to:   "a       x-b-c---y"
					fn: "+500"