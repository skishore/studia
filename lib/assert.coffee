# Add an assert method. Usage:
#   assert true, 'Damn. I was pretty sure that would be true.'

@assert = (condition, message) ->
  if not condition
    throw new AssertionError message
