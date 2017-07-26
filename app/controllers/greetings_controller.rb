class GreetingsController < ApplicationController
  before_filter :set_page_title_and_tab_active

  def index
    @greetings = Greeting.all
  end

  private

  def set_page_title_and_tab_active
    @page_title = "Greetings"
    @active = 'greetings'
  end
end
