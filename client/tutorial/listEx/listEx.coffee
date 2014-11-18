arr = new ReactiveArray ['Tom', 'Dick', 'Harry']

Template.listEx.helpers
  names: -> arr.list()

Template.listEx.events

  'click #listExAdd': ->
    arr.push $('#listExName').val()
    $('#listExName').val ''

  'click .listExRemove': ->
    arr.remove this.toString()