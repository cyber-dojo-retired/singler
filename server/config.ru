require_relative 'src/prometheus/collector'
require_relative 'src/prometheus/exporter'
require_relative 'src/external_disk_writer'
require_relative 'src/rack_dispatcher'
require_relative 'src/singler'
require 'rack'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

disk = ExternalDiskWriter.new
singler = Singler.new(disk)

run RackDispatcher.new(singler, Rack::Request)
