# Rails Queues Providers using ActiveJob

This project aim to try to use several queues providers with the data abstraction of ActiveJob.
The main providers for queue jobs are `Sidekiq` and `Shoryuken`.

`Sidekiq` works with `redis` as a queue manager.
`Shoryuken` is a fork of `sidekiq` and works with `AWS SQS` as a queue manager.

In this project you just to configure:
* Credentials of `AWS`
* Server settings of `redis` (in case you use `sidekiq`)

## Installation
1. Clone the project
    `$ git clone git@github.com:khrno/activejob-providers-benchmark.git demo`

2. Go to the project cloned:
    `$ cd demo`

3. Install dependencies
    `$ bundle install`

4. Run migrations
    `$ bundle exec rake db:migrate`
    
5. Start the server
    `$ bundle exec rails s`