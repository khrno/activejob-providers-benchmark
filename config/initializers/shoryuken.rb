require 'aws-sdk'
require 'uri'

if ENV['QUEUE_PROVIDER'].to_sym == :shoryuken
  queue_prefix = Rails.env
  queues = %w(critical-demo-queue default-demo-queue low-demo-queue)
  client =  Aws::SQS::Client.new(
    region: ENV['AWS_REGION'],
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  )

  aws_queues_names = client.list_queues.queue_urls.map{|queue_url| URI(queue_url).path.split('/').last}

  queues.each do |queue_name|
    queue_full_name = ENV['USE_PREFIX_QUEUE'] == 'true' ? "#{queue_prefix}_#{queue_name}" : queue_name
    unless aws_queues_names.include? queue_full_name
      puts "[SHORYUKEN] Notice: Creating queue #{queue_full_name } on AWS SQS"
      client.create_queue({queue_name: queue_full_name})
    end
  end
end

