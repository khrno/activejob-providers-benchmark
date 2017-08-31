class ApplicationWorker < ActiveJob::Base
  include DemoJob::Exceptions
end