class GreetingJob < ApplicationWorker
  queue_as 'low'

  def perform(name)
    Greeting.create(name: name, queue_provider: ENV['QUEUE_PROVIDER'])
    puts "Hello, #{name}"
  end
end
