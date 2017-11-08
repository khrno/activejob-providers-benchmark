class WorkOnRetriesJob < ApplicationWorker
  queue_as 'smallest'

  def perform(value)
    attempts = 5
    tries = 0
    wait = 2.seconds
    exception = StandardError
    begin
      tries += 1
      raise exception
      Greeting.create(name: "Finished correctly #{value}", queue_provider: ENV['QUEUE_PROVIDER'])
      worker_log "Job finished"
    rescue exception
      if tries < attempts
        worker_log "Retrying #{self.class} in #{wait} seconds, due to a #{exception}."
        sleep(wait)
        retry
      else
        worker_log "Stopped retrying #{self.class} due to a #{exception}, which reoccurred on #{tries} attempts."
        Greeting.create(name: "Work with value: #{value} was killed by retries with #{tries} executions", queue_provider: ENV['QUEUE_PROVIDER'])
      end
    end
  end

  private

  def worker_log(message)
    Rails.logger.debug "[WorkOnRetriesJob] #{message}"
  end
end
