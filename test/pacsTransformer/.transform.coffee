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
		pacsToString(pacs).should.equal to
		transformer.transform (p) ->
		from.should.equal pacsToString pacs

example.skip = (opts) -> example opts, 'skip'
example.only = (opts) -> example opts, 'only'

describe "PacsTransformer", ->

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

			describe "should try to keep external to extenral connections alive", ->

				describe "should preserve external to external connections interjected by existing selected points", ->

					example

						from: "a-x-b"
						to:   "a---b x"
						fn: "+400"

					example

						from: "a-x-y-b"
						to:   "a-----b x-y"
						fn: "+600"

					example

						from: "f a-x-b-y-c       d-e"
						to:   "f a---b---c x---y d-e"
						fn: "+800"

				example

					from: "a x b---c"
					to:   "a   b-x-c"
					fn: "+400"

				example

					from: "a x b-y-c"
					to:   "a   b-x-c y"
					fn: "+400"

				example

					from: "a x b-y-z-c"
					to:   "a   b---x-c y-z"
					fn: "+600"

			describe "should try to keep internal to internal connections alive", ->

				example

					from: "a x---y  b"
					to:   "a      x-b-y"
					fn: "+500"

				example

					from: "a x-----y b c"
					to:   "a       x-b-c-y"
					fn: "+600"

				example

					from: "a x-y b-----c"
					to:   "a     b-x-y-c"
					fn: "+600"

				it "some example", ->

					one   = "a-x---y-b c--------d"
					two   = "a-------b c--x---y-d"
					three = "a-------b c-x---y--d"
					four  = "a-------b c------x-d-y"
					five  = "a-------b c--------d x---y"

					{pacs, transformer} = stringToStuff one

					transformer.transform (p) -> p.time += 1100
					two.should.equal pacsToString pacs

					transformer.transform (p) -> p.time += 1000
					three.should.equal pacsToString pacs

					transformer.transform (p) -> p.time += 1500
					four.should.equal pacsToString pacs

					transformer.transform (p) -> p.time += 1900
					five.should.equal pacsToString pacs