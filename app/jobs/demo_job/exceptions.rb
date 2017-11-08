module DemoJob
  module Exceptions
    extend ActiveSupport::Concern

    # included do
    #   # Number of times this job has been executed (which increments on every retry, like after an exception).
    #   attr_accessor :executions
    #
    #   before_perform do |job|
    #     job.executions = (job.executions || 0) + 1
    #   end
    # end

    # class ActiveJob::Base
    #   def self.deserialize(job_data)
    #     job = job_data['job_class'].constantize.new
    #     job.job_id = job_data['job_id']
    #     job.queue_name = job_data['queue_name']
    #     job.serialized_arguments = job_data['arguments']
    #     job.locale = job_data['locale'] || I18n.locale
    #     job.executions = job_data['executions']
    #     job
    #   end
    # end

    module ClassMethods
      def retry_on(exception, wait, attempts, queue)
        rescue_from exception do |error|
          if executions < attempts
            logger.error "Retrying #{self.class} in #{wait} seconds, due to a #{exception}. The original exception was #{error.cause.inspect}."
            retry_job wait: determine_delay(wait), queue: queue
          else
            if block_given?
              yield self, exception
            else
              logger.error "Stopped retrying #{self.class} due to a #{exception}, which reoccurred on #{executions} attempts. The original exception was #{error.cause.inspect}."
              raise error
            end
          end
        end
      end
    end

    # def initialize(*arguments)
    #   super(*arguments)
    #   @executions = 0
    # end
    #
    # def serialize
    #   job_data = super
    #   job_data['executions'] = @executions
    #   job_data
    # end

    private

    # def determine_delay(seconds_or_duration_or_algorithm)
    #   case seconds_or_duration_or_algorithm
    #     when :exponentially_longer
    #       (executions**4) + 2
    #     when ActiveSupport::Duration
    #       duration = seconds_or_duration_or_algorithm
    #       duration.to_i
    #     when Integer
    #       seconds = seconds_or_duration_or_algorithm
    #       seconds
    #     when Proc
    #       algorithm = seconds_or_duration_or_algorithm
    #       algorithm.call(executions)
    #     else
    #       raise "Couldn't determine a delay based on #{seconds_or_duration_or_algorithm.inspect}"
    #   end
    # end
  end
end
