Future = Npm.require 'fibers/future'
request = Npm.require 'request'


class @FileStore
  # Choose between different FileStore backends here.
  @Backend = MongoFileStore

  @get_file: (uuid) =>
    @Backend.get_file uuid

  @save_file = (data) =>
    if data.length > Common.max_size
      throw new ValueError \
        "File was too large (maximum size: #{data.length >> 20} MB)"
    @Backend.save_file data

  @save_url = (url) =>
    if not url
      throw new ValueError 'Tried to save empty url!'
    future = new Future
    options = {url: url, encoding: null}
    request.get options, (error, result, body) ->
      if error
        return future.throw new ValueError error.message
      if result.statusCode != 200
        return future.throw new ValueError \
          "GET returned status code #{result.statusCode} (expected 200)"
      content_type = result.headers['content-type']
      if content_type != Common.MIME_type
        return future.throw new ValueError \
          "Got #{content_type} (expected #{Common.MIME_type})"
      future.return "data:#{content_type};base64,#{body.toString 'base64'}"
    @Backend.save_file do future.wait
