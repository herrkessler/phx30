module GoogleDistanceMatrix
  # Public: Error class for lib.
  class Error < StandardError
  end

  # Public: Matrix has errors.
  class InvalidMatrix < Error
    def initialize(matrix)
      @matrix = matrix
    end

    def to_s
      @matrix.errors.full_messages.to_sentence
    end
  end

  # Public: Route seems invalid
  #
  # Fails if a route is built, but it's status from
  # Google isn't OK.
  #
  class InvalidRoute < Error
    def initialize(route)
      @route = route
    end

    def to_s
      "API did not provide a complete answer for #{@route}."
    end
  end

  # Public: Got a request error back trying to do a request
  #
  # This includes wire errors like timeouts etc, and server errors
  # like 5xx. Inspect error_or_response for more information.
  #
  class ServerError < Error
    attr_reader :error_or_response

    def initialize(error_or_response)
      @error_or_response = error_or_response
    end

    def to_s
      "GoogleDistanceMatrix::ServerError - #{error_or_response.inspect}."
    end
  end

  # Public: Got an error where the client seems to be doing something wrong
  #
  # These errors comes from http 4xx errors, or API errors like MAX_ELEMENTS_EXCEEDED etc.
  # See https://developers.google.com/maps/documentation/distancematrix/#StatusCodes for info.
  #
  class ClientError < Error
    attr_reader :response, :status_read_from_api_response

    def initialize(response, status_read_from_api_response = nil)
      @response = response
      @status_read_from_api_response = status_read_from_api_response
    end

    def to_s
      "GoogleDistanceMatrix::ClientError - #{[response, status_read_from_api_response].compact.join('. ')}."
    end
  end

  # Public: API URL was too long
  #
  # See https://developers.google.com/maps/documentation/distancematrix/#Limits, which states:
  # "Distance Matrix API URLs are restricted to 2048 characters, before URL encoding."
  # "As some Distance Matrix API service URLs may involve many locations, be aware of this limit when constructing your URLs."
  #
  class MatrixUrlTooLong < ClientError
    attr_reader :url, :max_url_size

    def initialize(url, max_url_size, response = nil)
      super response

      @url = url
      @max_url_size = max_url_size
    end

    def to_s
      "Matrix API URL max size is: #{max_url_size}. Built URL was: #{url.length}. URL: '#{url}'."
    end
  end

end
