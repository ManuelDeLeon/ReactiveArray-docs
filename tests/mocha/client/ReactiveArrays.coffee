if typeof MochaWeb isnt 'undefined'
  MochaWeb.testOnly ->
    objectsAreEqual = (obj1, obj2) ->
      return false if obj1.length isnt obj2.length
      for p of obj1
        return false if obj1[p] isnt obj2[p]
      true

    arrEquals = (a1, a2) ->
      return false if a1.length isnt a2.length
      i = 0
      while i < a1.length
        return false if a1[i] isnt a2[i]
        i++
      true

    describe "ReactiveArray", ->
      arr = null
      beforeEach ->
        arr = new ReactiveArray ['a', 'b']

      describe "New ReactiveArray", ->
        it "should have array values", ->
          chai.assert.equal arr.length, 2
          chai.assert.equal arr[0], 'a'
          chai.assert.equal arr[1], 'b'

        it "should be instance of Array", ->
          chai.assert.isTrue arr instanceof Array

      describe "push", ->
        it "should return the array length", ->
          ret = arr.push 'c', 'd'
          chai.assert.equal ret, 4

        it "should add item to array", ->
          arr.push 'c'
          chai.assert.equal arr.length, 3
          chai.assert.equal arr[0], 'a'
          chai.assert.equal arr[1], 'b'
          chai.assert.equal arr[2], 'c'

        it "should notify", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr[2], 'c'
              c.stop()
              done()

          arr.push 'c'

        it "should not notify when paused", (done) ->
          changed = false
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              changed = true
              c.stop()
          arr.pause()
          arr.push 'c'
          Global.delay 15, ->
            chai.assert.isFalse changed
            done()

        it "should notify when resumed", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr[2], 'c'
              c.stop()
              done()
          arr.pause()
          arr.push 'c'
          arr.resume()

      describe "pop", ->
        it "should return the item", ->
          ret = arr.pop()
          chai.assert.equal ret, 'b'

        it "should remove last item", ->
          arr.pop()
          chai.assert.equal arr.length, 1
          chai.assert.equal arr[0], 'a'

        it "should notify", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr.length, 1
              chai.assert.equal arr[0], 'a'
              c.stop()
              done()

          arr.pop()

        it "should not notify when paused", (done) ->
          changed = false
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              changed = true
              c.stop()
          arr.pause()
          arr.pop()
          Global.delay 15, ->
            chai.assert.isFalse changed
            done()

        it "should notify when resumed", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr.length, 1
              chai.assert.equal arr[0], 'a'
              c.stop()
              done()
          arr.pause()
          arr.pop()
          arr.resume()

      describe "list", ->
        it "should work without parameters", (done) ->
          ra = new ReactiveArray()
          Tracker.autorun (c) ->
            a = ra.list()
            if not c.firstRun
              chai.assert.equal a.length, 1
              chai.assert.equal a[0], 'a'
              chai.assert.equal ra.length, 1
              chai.assert.equal ra[0], 'a'
              c.stop()
              done()
          ra.push 'a'

        it "should work with an array", (done) ->
          ra = new ReactiveArray(['a'])
          Tracker.autorun (c) ->
            a = ra.list()
            if not c.firstRun
              chai.assert.equal a.length, 2
              chai.assert.equal a[0], 'a'
              chai.assert.equal a[1], 'b'
              c.stop()
              done()
          ra.push 'b'

        it "should work with an array and a dep", (done) ->
          dep = new Tracker.Dependency()
          ra = new ReactiveArray(['a'], dep)
          Tracker.autorun (c) ->
            dep.depend()
            if not c.firstRun
              chai.assert.equal ra.length, 2
              chai.assert.equal ra[0], 'a'
              chai.assert.equal ra[1], 'b'
              c.stop()
              done()
          ra.push 'b'

      describe "depend", ->
        it "should be reactive", (done) ->
          ra = new ReactiveArray()
          Tracker.autorun (c) ->
            a = ra.depend()
            if not c.firstRun
              chai.assert.equal a.length, 1
              chai.assert.equal a[0], 'a'
              chai.assert.equal ra.length, 1
              chai.assert.equal ra[0], 'a'
              c.stop()
              done()
          ra.push 'a'

      describe "array", ->
        it "should be reactive", (done) ->
          ra = new ReactiveArray()
          Tracker.autorun (c) ->
            a = ra.array()
            if not c.firstRun
              chai.assert.isFalse a instanceof ReactiveArray
              chai.assert.equal a.length, 1
              chai.assert.equal a[0], 'a'
              chai.assert.equal ra.length, 1
              chai.assert.equal ra[0], 'a'
              c.stop()
              done()
          ra.push 'a'

      describe "concat", ->
        it "should work with a reactive array", (done) ->
          ra = new ReactiveArray ['c']
          newArr = arr.concat ra
          chai.assert.equal newArr.length, 3
          chai.assert.equal newArr[0], 'a'
          chai.assert.equal newArr[1], 'b'
          chai.assert.equal newArr[2], 'c'

          Tracker.autorun (c) ->
            newArr.depend()
            if not c.firstRun
              chai.assert.equal newArr.length, 4
              chai.assert.equal newArr[0], 'a'
              chai.assert.equal newArr[1], 'b'
              chai.assert.equal newArr[2], 'c'
              chai.assert.equal newArr[3], 'd'

              c.stop()
              done()
          newArr.push 'd'

        it "should work with a normal array", (done) ->
          newArr = arr.concat ['c']
          chai.assert.equal newArr.length, 3
          chai.assert.equal newArr[0], 'a'
          chai.assert.equal newArr[1], 'b'
          chai.assert.equal newArr[2], 'c'

          Tracker.autorun (c) ->
            newArr.depend()
            if not c.firstRun
              chai.assert.equal newArr.length, 4
              chai.assert.equal newArr[0], 'a'
              chai.assert.equal newArr[1], 'b'
              chai.assert.equal newArr[2], 'c'
              chai.assert.equal newArr[3], 'd'

              c.stop()
              done()
          newArr.push 'd'

        it "should work with multiple params", (done) ->
          ra = new ReactiveArray ['c']
          newArr = arr.concat ra, ['d'], 'e'
          chai.assert.equal newArr.length, 5
          chai.assert.equal newArr[0], 'a'
          chai.assert.equal newArr[1], 'b'
          chai.assert.equal newArr[2], 'c'
          chai.assert.equal newArr[3], 'd'
          chai.assert.equal newArr[4], 'e'

          Tracker.autorun (c) ->
            newArr.depend()
            if not c.firstRun
              chai.assert.equal newArr.length, 6
              chai.assert.equal newArr[0], 'a'
              chai.assert.equal newArr[1], 'b'
              chai.assert.equal newArr[2], 'c'
              chai.assert.equal newArr[3], 'd'
              chai.assert.equal newArr[4], 'e'
              chai.assert.equal newArr[5], 'f'

              c.stop()
              done()
          newArr.push 'f'

        it "should work with a string", (done) ->
          newArr = arr.concat 'c'
          chai.assert.equal newArr.length, 3
          chai.assert.equal newArr[0], 'a'
          chai.assert.equal newArr[1], 'b'
          chai.assert.equal newArr[2], 'c'

          Tracker.autorun (c) ->
            newArr.depend()
            if not c.firstRun
              chai.assert.equal newArr.length, 4
              chai.assert.equal newArr[0], 'a'
              chai.assert.equal newArr[1], 'b'
              chai.assert.equal newArr[2], 'c'
              chai.assert.equal newArr[3], 'd'

              c.stop()
              done()
          newArr.push 'd'

      describe "indexOf", ->
        it "should be reactive", (done) ->
          i = arr.indexOf 'c'
          chai.assert.equal i, -1
          Tracker.autorun (c) ->
            i = arr.indexOf 'c'
            if not c.firstRun
              chai.assert.equal i, 2
              c.stop()
              done()
          arr.push 'c'

        it "should work with starting index",  ->
          arr.push 'c'
          arr.push 'd'
          arr.push 'c'
          i = arr.indexOf 'c', 3
          chai.assert.equal i, 4

      describe "join", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            s = arr.join()
            if not c.firstRun
              chai.assert.equal s, "a,b,c"
              c.stop()
              done()
          arr.push 'c'

        it "should work with a separator",  ->
          s = arr.join '-'
          chai.assert.equal s, "a-b"

      describe "lastIndexOf", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            i = arr.lastIndexOf 'b'
            if not c.firstRun
              chai.assert.equal i, 1
              c.stop()
              done()
          arr.push 'c'

        it "should work normally",  ->
          array = new ReactiveArray [2, 5, 9, 2]
          index = array.lastIndexOf(2)
          chai.assert.equal index, 3
          index = array.lastIndexOf(7)
          chai.assert.equal index, -1
          index = array.lastIndexOf(2, 3)
          chai.assert.equal index, 3
          index = array.lastIndexOf(2, 2)
          chai.assert.equal index, 0
          index = array.lastIndexOf(2, -2)
          chai.assert.equal index, 0
          index = array.lastIndexOf(2, -1)
          chai.assert.equal index, 3

      describe "clear", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            s = arr.array()
            if not c.firstRun
              chai.assert.equal s.length, 0
              c.stop()
              done()
          a = arr.clear()
          chai.assert.isTrue a instanceof ReactiveArray

      describe "reverse", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            newArr = arr.array()
            if not c.firstRun
              chai.assert.equal newArr.length, 2
              chai.assert.equal newArr[0], 'b'
              chai.assert.equal newArr[1], 'a'
              c.stop()
              done()
          arr.reverse()

      describe "shift", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr.length, 1
              chai.assert.equal arr[0], 'b'
              c.stop()
              done()

          e = arr.shift()
          chai.assert.equal e, 'a'

      describe "sort", ->
        it "should be reactive", (done) ->
          arr.push 'd','c'
          Tracker.autorun (c) ->
            newArr = arr.array()
            if not c.firstRun
              chai.assert.equal newArr.length, 4
              chai.assert.equal newArr[0], 'a'
              chai.assert.equal newArr[1], 'b'
              chai.assert.equal newArr[2], 'c'
              chai.assert.equal newArr[3], 'd'
              c.stop()
              done()
          arr.sort()

          it "should work with a function", ->
            arr = new ReactiveArray [3,2,4,1]
            arr.sort (a,b) -> a - b
            chai.assert.equal arr.length, 4
            chai.assert.equal arr[0], 1
            chai.assert.equal arr[1], 2
            chai.assert.equal arr[2], 3
            chai.assert.equal arr[3], 4

      describe "splice", ->
        it "should work normally", ->
          myFish = new ReactiveArray ['angel', 'clown', 'mandarin', 'surgeon']

          # removes 0 elements from index 2, and inserts 'drum'
          removed = myFish.splice(2, 0, 'drum')
          chai.assert.isTrue arrEquals( myFish, ['angel', 'clown', 'drum', 'mandarin', 'surgeon'] )
          chai.assert.isTrue arrEquals( removed, [] )

          # removes 1 element from index 3
          removed = myFish.splice(3, 1)
          chai.assert.isTrue arrEquals( myFish, ['angel', 'clown', 'drum', 'surgeon'] )
          chai.assert.isTrue arrEquals( removed, ['mandarin'] )

          # removes 1 element from index 2, and inserts 'trumpet'
          removed = myFish.splice(2, 1, 'trumpet')
          chai.assert.isTrue arrEquals( myFish, ['angel', 'clown', 'trumpet', 'surgeon'] )
          chai.assert.isTrue arrEquals( removed, ['drum'] )

          # removes 2 elements from index 0, and inserts 'parrot', 'anemone' and 'blue'
          removed = myFish.splice(0, 2, 'parrot', 'anemone', 'blue')
          chai.assert.isTrue arrEquals( myFish, ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon'] )
          chai.assert.isTrue arrEquals( removed, ['angel', 'clown'] )

          # removes 2 elements from index 3
          removed = myFish.splice(3, Number.MAX_VALUE)
          chai.assert.isTrue arrEquals( myFish, ['parrot', 'anemone', 'blue'] )
          chai.assert.isTrue arrEquals( removed, ['trumpet', 'surgeon'] )

        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            newArr = arr.array()
            if not c.firstRun
              chai.assert.equal newArr.length, 1
              chai.assert.equal newArr[0], 'b'
              c.stop()
              done()
          arr.splice(0, 1)

      describe "toString", ->
        it "should be reactive", (done) ->
          Tracker.autorun (c) ->
            s = arr.toString()
            if not c.firstRun
              chai.assert.equal s, "a,b,c"
              c.stop()
              done()
          arr.push 'c'


      describe "unshift", ->
        it "should return the array length", ->
          ret = arr.unshift 'c', 'd'
          chai.assert.equal ret, 4

        it "should add item to array", ->
          arr.unshift 'c'
          chai.assert.equal arr.length, 3
          chai.assert.equal arr[0], 'c'
          chai.assert.equal arr[1], 'a'
          chai.assert.equal arr[2], 'b'

        it "should notify", (done) ->
          Tracker.autorun (c) ->
            a = arr.list()
            if not c.firstRun
              chai.assert.equal arr[0], 'c'
              c.stop()
              done()

          arr.unshift 'c'