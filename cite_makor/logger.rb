require 'logger' # avoid name clash with stdlib Logger by requiring it first

module CiteMakor
  Logger = ::Logger.new(STDOUT)
end
