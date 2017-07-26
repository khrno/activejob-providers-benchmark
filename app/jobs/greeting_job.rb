class GreetingJob < ActiveJob::Base
  queue_as 'default-demo-queue'

  def perform(name)
    Greeting.create(name: name, queue_provider: ENV['QUEUE_PROVIDER'])
    puts "Hello, #{name}"
  end
end
