# Add a String.strip function that returns a new string with whitespace removed
# from the beginning and end of the string.

if not String.prototype.strip?
  String.prototype.strip = ->
    String(this).replace /^\s+|\s+$/g, ''
