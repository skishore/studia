# Error pseudo-classes. Usage:
#   throw new ValueError 'square_root() was called with a negative number.'

stack = ->
  # Strip out the first four lines, which are tracebacks from the
  # exception function / register_ugli_error / stack calls.
  stack_lines = new Error().stack.split '\n'
  stack_lines.splice(3).join '\n'

register_error = (type) ->
  @[type] = class CustomError extends Meteor.Error
    constructor: (message) ->
      @error = message
      @details = "#{type}: #{message}\n#{stack()}"
      console.error @details

register_error 'AssertionError'
register_error 'NotImplementedError'
register_error 'ValueError'
