class WelcomeController < ApplicationController
  before_filter :generate_random_name, except: [:index]

  def index
    @page_title = 'Send to SQS'
  end

  def send_job_now
    GreetingJob.perform_now(@name)
    redirect_to greetings_url, notice: 'job was sent successfully'
  end

  def send_job_later
    GreetingJob.perform_later(@name)
    redirect_to greetings_url, notice: 'job was sent successfully'
  end

  private
  def generate_random_name
    @name = Faker::StarWars.character
  end

  def job_params
    params.require(:job_arguments).permit(:name)
  end
end
