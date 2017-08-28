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
    ```bash
    $ git clone git@github.com:khrno/activejob-providers-benchmark.git demo
    ```
2. Go to the project cloned:
    ```bash
    $ cd demo
    ```

3. Install dependencies
    ```bash
    $ bundle install
    ```
3. Create the database
    ```bash
    $ bundle exec rake db:create
    ```
    
4. Run migrations
    ```bash
    $ bundle exec rake db:migrate
    ```
    
5. Start the server
    ```bash
    $ bundle exec rails s
    ```
    
### Sidekiq
To run sidekiq, you need a server of `redis`. [Quickstart](https://redis.io/topics/quickstart). Then you need start `sidekiq`

```bash
$ bundle exec sidekiq
```

### Shoryuken
You need to create a queue in [`AWS SQS`](https://aws.amazon.com/sqs/). Then you need to start shoryuken with the rails configuration.

```bash
$  bundle exec shoryuken -q [QUEUE-NAME] -R
```
