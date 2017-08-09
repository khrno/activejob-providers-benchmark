class LongJobJob < ActiveJob::Base
  queue_as 'critical-demo-queue'

  def perform(title)
    tstart = Time.zone.now
    Rails.logger.debug "[LongJobJob] start execution at #{tstart}"
    tracked_register = TrackedExecution.create(title: title, start: tstart)

    sleep(60)
    tend = Time.zone.now
    Rails.logger.debug "[LongJobJob] end execution at #{tend}"
    tracked_register.update_attribute(:end, tend)
  end
end
