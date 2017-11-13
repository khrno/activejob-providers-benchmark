require 'aws-sdk'
require 'uri'

def visibility_timeout(queue_name)
  case queue_name
    when 'low'
      return '14400'
    when 'default'
      return '120'
    when 'critical'
      return '900'
    when 'smallest'
      return '1'
    else
      return '30'
  end
end

def max_receive_count(queue_name)
  case queue_name
    when 'low'
      return '5'
    when 'default'
      return '10'
    when 'critical'
      return '15'
    when 'smallest'
      return '20'
    else
      return '10'
  end
end

if ENV['QUEUE_PROVIDER'] && ENV['QUEUE_PROVIDER'].to_sym == :shoryuken
  Shoryuken.active_job_queue_name_prefixing = true


  queue_prefix = ENV['PLATFORM_UUID']
  client =  Aws::SQS::Client.new
  aws_name_url = client.list_queues.queue_urls
                   .map { |queue_url| { queue_url[URI(queue_url).path.split('/').last] => queue_url[queue_url] } }
                   .reduce({}, :merge)


  # Verify if a queue named dead-letter-queue exists
  # If exists, get the dead-letter-queue arn
  # Else, create and get the arn
  dead_letter_queue_fullname = queue_prefix ? "#{queue_prefix}_dead_letter_queue" : "dead_letter_queue"
  if aws_name_url.keys.include? dead_letter_queue_fullname
    dead_letter_queue_url = aws_name_url[dead_letter_queue_fullname]
    aws_name_url.except!(dead_letter_queue_fullname)
  else
    dead_letter_queue_url = client.create_queue({ queue_name: dead_letter_queue_fullname}).queue_url
  end
  dead_letter_queue_attributes = client.get_queue_attributes({queue_url: dead_letter_queue_url, attribute_names:['QueueArn']})
  dead_letter_queue_arn = dead_letter_queue_attributes.attributes['QueueArn'] if dead_letter_queue_attributes


  Shoryuken.options[:queues].each do |queue_name|
    attributes = {}
    # queue_name[0] name of queue in queues parameters
    # queue_name[1] round robin weight of queue in queues parameters
    # queue_name[2] attributes of queue in queues parameters. Format: {options: {VisibilityTimeout: '123'}}
    if queue_name[2]&.[](:options)&.[](:VisibilityTimeout)
      attributes[:VisibilityTimeout] = queue_name[2][:options][:VisibilityTimeout]
    else
      attributes[:VisibilityTimeout] = visibility_timeout(queue_name[0].split('_').last)
    end

    if queue_name[2]&.[](:options)&.[](:maxReceiveCount)
      attributes[:RedrivePolicy] = {
        'deadLetterTargetArn': dead_letter_queue_arn,
        'maxReceiveCount': queue_name[2]&.[](:options)&.[](:maxReceiveCount)
      }.to_json
    else
      attributes[:RedrivePolicy] = {
        'deadLetterTargetArn': dead_letter_queue_arn,
        'maxReceiveCount': max_receive_count(queue_name[0].split('_').last)
      }.to_json
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