class WorkOnRetriesJob < ApplicationWorker
  queue_as 'default-demo-queue'

  retry_on(StandardError,1.seconds, 5, 'default-demo-queue') do |job, exception|
    Greeting.create(name: "Work with value: #{job.arguments[0]} was killed by retries with #{job.executions} executions", queue_provider: ENV['QUEUE_PROVIDER'])
  end

  def perform(value)
    worker_log "Starting job with #{value}"
    raise StandardError
    Greeting.create(name: "Finished correctly #{value}", queue_provider: ENV['QUEUE_PROVIDER'])
    worker_log "Job finished"
  end

  private

  def worker_log(message)
    Rails.logger.debug "[WorkOnRetriesJob] #{message}"
  end
end