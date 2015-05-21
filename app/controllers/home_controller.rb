class HomeController < ApplicationController

  require 'open-uri'
  require 'json'

  def index

    if logged_in?
  # get user interest from the database
  @user = current_user
  @interest_pre = @user.interest1
  puts @user.to_s
  puts @user.interest1
  @interest = @interest_pre.gsub(' ','+') # add + symbol between each word if there are 2+ words to allow use in http searches - designates "or" in the article searches
  @zipcode = @user.zipcode

  free_pre = @user.free_time  
  @free_time = free_pre.gsub(' ', '+') # add + symbol between each word if there are 2+ words to allow use in http searches - designates "or" in the event searches
  
  # call api methods and insert interest into api call

  @nytimes_data = data_retrieve("http://api.nytimes.com/svc/search/v2/articlesearch.json?&q=" + current_user.interest1 + "&sort=newest&api-key=bd2d3da37f58e2247ab30155400fc222:3:67128716")
  @weather_rpt = data_retrieve("http://api.wunderground.com/api/cfffe9ffeb7b662e/conditions/q/" + current_user.state + "/" + current_user.city + ".json")
  @weather_forecast = data_retrieve("http://api.wunderground.com/api/cfffe9ffeb7b662e/forecast/q/" + current_user.state + "/" + current_user.city + ".json")
  @meetup_data = data_retrieve("https://api.meetup.com/2/open_events?&sign=true&photo-host=public&zip=" + current_user.zipcode + "&text=" + @interest + "&page=20&key=6874237675483c4f5e12f416939655a")
  @nytimes_top = data_retrieve("http://api.nytimes.com/svc/topstories/v1/home.json?api-key=799bb4a946ced430d7d8611ca957387b:8:67128716")
  @nytimes_events = data_retrieve("http://api.nytimes.com/svc/events/v2/listings.json?&query=" + @free_time + "&api-key=3484b827fcc7f7a5962abbf4b36fdfc4:19:67128716")

  # check if any results are empty or nil and if so assign a default string
  
  
  @weather_current = @weather_rpt['current_observation']["temperature_string"]
  if @weather_current.empty
    @weather_current = "No weather forecast information at this time"
    @weather_wind, @weather_humidity, @weather_feels, @weather_ftext, @weather_day = "No information at this time"
  else
  @weather_wind = @weather_rpt['current_observation']["wind_string"]
  @weather_humidity = @weather_rpt['current_observation']["relative_humidity"]
  @weather_feels = @weather_rpt['current_observation']["feelslike_string"]

  @weather_ftext = @weather_forecast["forecast"]["txt_forecast"]["forecastday"]["fcttext"]
  @weather_day = @weather_forecast["forecast"]["txt_forecast"]["forecastday"]["title"]
  # @weather_fnextdaytext = []
end

  top_stories
  articles
  networking
  events

else
  render 'index'

end



end

  # assign json array info to variables
  
  
  def top_stories   # Top stories
    @top_title = @nytimes_top["results"]["title"] # with title being the link_to to the 'url'; 
    if @top_title.empty
      @top_title = "Unable to retrieve top stories at this time" 
      @top_url, @top_date = "No information at this time"
    else
    @top_url = @nytimes_top["results"]["url"]
    @top_date = @nytimes_top["results"]["last_updated"]
  end
end


  def articles    # Article search
    @headline = @vnytimes_data["response"]["docs"]["headline"]["main"]
    if @headline.empty 
     @headline = "No news on your interests at this time" # test if there is data
     @art_date, @art_url = "No information at this time"
  else
    @art_date = @nytimes_data["response"]["docs"]["pub_date"]
    @art_url = @nytimes_data["response"]["docs"]["web_url"]
  end
end

  def networking
    @meetup_grpname = @meetup_data["results"]["group"]["name"]
    if @meetup_grpname.empty
      @meetup_grpname = "No information on meetup groups" 
      @meetup_locname, @meetup_address, @meetup_city, @meetup_desc, @meetup_url, @meetup_status = "No information at this time"
    else
    @meetup_locname = @meetup_data["results"]["venue"]["name"]
    @meetup_address = @meetup_data["results"]["venue"]["address1"]
    @meetup_city = @meetup_data["results"]["venue"]["city"]
    @meetup_desc = @meetup_data["results"]["name"]
    @meetup_url = @meetup_data["results"]["event_url"]
    @meetup_status = @meetup_data["results"]["status"]

  end
end

  def events   # Events
    @events_desc = @nytimes_events["results"]["web_description"]  # description of event
    if @events_desc.empty
      @events_desc = "No information on local events meeting your free time interest"
      @events_name, @events_url, @events_free = "No information at this time"
    else
    @events_name = @nytimes_events["results"]["event_name"]
    # @events_date = @nytimes_events["results"][""]
    @events_url = @nytimes_events["results"]["event_detail_url"]
    @events_free = @nytimes_events["results"]["free"]
  end
end

  def data_retrieve(url_string)
    url = url_string
    data_read =open(url).read
    data_result = JSON.parse(data_read)
    return
  end



  private

  def nytimes
    # insert api into nytimes api call
    # url = "http://api.nytimes.com/svc/search/v2/articlesearch.json?&q=" + @interest1 "+" + @interest2 + "&sort=newest&api-key=bd2d3da37f58e2247ab30155400fc222:3:67128716"
    # nyt_data = open(url).read
    # now parse and put into an array (shown below)
    # nyt_result = JSON.parse(nyt_data)
 
  end


  def meetup
    # insert api into meetup api call
    # url = "https://api.meetup.com/2/open_events.zip=" + self.zipcode + "&text=" + @interest1 + "+" + @interest2 + "&time=,1m&key=6874237675483c4f5e12f416939655a"
    # meetup_data = open(url).read
    # now parse and put into an array (shown below)
    # meetup_result = JSON.parse(meetup_data)

  end


  def indeed
    # insert api into meetup api call
    # url = "http://api.indeed.com/ads/apisearch?publisher=3117837613642246&q=" + @interest1 + "+" @interest2 + "&l=" + @zipcode + 
    #{ }"&sort=&radius=5&st=&jt=&start=&limit=50&fromage=15&filter=&latlong=0&co=us&chnl=&userip=" + machine ip + "&useragent=" + browser + "&v=2"

    # indeed_data = open(url).read
    # now parse and put into an array (shown below)
    # groups_result = XML.parse(groups_data) # check what is the correct method to parse to XML
  end

  def weather_rpt
    # @user_state = User.state
    # @user_city = User.city
    # url = "http://api.wunderground.com/api/cfffe9ffeb7b662e/conditions/q/" + User.state + "/" + User.city + ".json"
    # weather_data = open(url).read
    # weather_result = JSON.parse(weather_data)
  end

  def freetime
    # @user.zipcode = User.zipcode
    # url = 
    # freetime_data = open(url).read
    # freetime_events = JSON.parse(freetime_data)
  end

  def top_stories
    # url = 
    # top_data = open(url).read
    # top_info = JSON.parse(top_data)
  end


  # end of class
  
  end
