require 'aws-sdk'
require 'uri'

if ENV['QUEUE_PROVIDER'] && ENV['QUEUE_PROVIDER'].to_sym == :shoryuken
  Shoryuken.active_job_queue_name_prefixing = true

  queue_prefix = ENV['PLATFORM_UUID']
  client =  Aws::SQS::Client.new
  aws_name_url = client.list_queues.queue_urls
                   .map { |queue_url| { queue_url[URI(queue_url).path.split('/').last] => queue_url[queue_url] } }
                   .reduce({}, :merge)
  Shoryuken.options[:queues].each do |queue_name|
    attributes = {}
    # queue_name[0] name of queue in queues parameters
    # queue_name[1] round robin weight of queue in queues parameters
    # queue_name[2] attributes of queue in queues parameters. Format: {options: {VisibilityTimeout: '123'}}
    if queue_name[2]&.[](:options)&.[](:VisibilityTimeout)
      attributes[:VisibilityTimeout] = queue_name[2][:options][:VisibilityTimeout]
    else
      case queue_name[0].split('_').last
        when 'low'
          attributes[:VisibilityTimeout] = '14400'
        when 'default'
          attributes[:VisibilityTimeout] = '30'
        when 'critical'
          attributes[:VisibilityTimeout] = '900'
        when 'smallest'
          attributes[:VisibilityTimeout] = '1'
        else
          attributes[:VisibilityTimeout] = '30'
      end
    end

    if queue_name[2]&.[](:options)&.[](:maxReceiveCount)
      attributes[:RedrivePolicy] = {
        'deadLetterTargetArn': 'arn:aws:sqs:us-east-1:745925809396:dead-letter-queue',
        'maxReceiveCount': queue_name[2]&.[](:options)&.[](:maxReceiveCount)}.to_json
    else
      attributes[:RedrivePolicy] = {
        'deadLetterTargetArn': 'arn:aws:sqs:us-east-1:745925809396:dead-letter-queue',
        'maxReceiveCount': '5'}.to_json
    end



    queue_full_name = queue_prefix ? "#{queue_prefix}_#{queue_name[0]}" : queue_name[0]
    if aws_name_url[queue_full_name]
      puts "[SHORYUKEN] Notice: Updating queue #{queue_full_name } on AWS SQS"
      client.set_queue_attributes({ queue_url: aws_name_url[queue_full_name], attributes: attributes })
    else
      puts "[SHORYUKEN] Notice: Creating queue #{queue_full_name } on AWS SQS"
      client.create_queue({ queue_name: queue_full_name, attributes: attributes })
    end
  end

end