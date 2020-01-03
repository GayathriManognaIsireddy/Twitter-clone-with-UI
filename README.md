
#TWITTER IMPLEMENTATION with Web Sockets- COP5615: Fall 2019

TEAM INFO
--------------------------------------------------------------------------------------------------------
Chandan Chowdary Kandipati (UFID 6972-9002)
Gayathri Manogna Isireddy (UFID 9124-0699)

PROBLEM STATEMENT
--------------------------------------------------------------------------------------------------------

The goal of this project is implementation of Twitter Clone engine and a simulator which is paired up with WebSockets to provide front end functionality.

WHAT IS WORKING
--------------------------------------------------------------------------------------------------------------
In 4.1: 
 Following Functionalities are implemented:
	* Register/Login account
	* Send tweet. Tweets can have hashtags and user-mentions
	* Subscribe to user's tweets
	* Re-tweets
	* Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned 
	* If the user is connected, deliver the above types of tweets live (without querying)
In 4.2:
All the below functionalities are working:
 - Implemented a simulation with at least 100 users. 
 - Implemented a web interface for the simulator created in project 4.1, using phoenix webSockets.
 - We implemented all the functionalities that are present in 4.1.

Steps to follow:
---------------------

  * Created a new phoenix project with `mix phx.new TwitterClone`
To start your Phoenix server:
  * Install dependencies with `mix deps.get`
  * Create database with `mix ecto.create`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
* To create a channel use the following command mix phx.gen.channel <channel_name>

Running the project:
---------------------
To run the simulator:
The socket must be imported from the simulator js file. To do this we must enable only the import from simulator js file in app.js.

To run the individual project we need to do the other way. Uncomment the import from ./socket_new and comment import from socket_simulation.

Once this is done the server will be running in the background and the web application can be accessed on the url:
http://localhost:4000/user_profile  -  individual user
https://localhost:4000/simulator  -  for simulator
  
In the individual part to open multiple users we can open multiple windows and register each user. All the functionalities are displayed on the User interface.


The demo video of the project can be seen here:
https://youtu.be/XtuZI7LJDfg

