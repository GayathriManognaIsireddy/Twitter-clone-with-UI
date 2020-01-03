defmodule TwittercloneWeb.RoomChannel do
  use Phoenix.Channel

  def join("twitterChannel:lobby", _message, socket) do
      {:ok, socket}
  end

  def join("twitterChannel:"<> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
  end

  def handle_in("username_button", params, socket) do
    IO.puts("in channel")
    userName = params["username"]
    IndividualClient.createActor(userName,self())
    IO.puts("hey hi")
    # GenServer.call(:server, {:register_node, userName, "password"}, :infinity)
    # GenServer.call(:server, {:login_node, userName, "password"}, :infinity)
    push socket, "registered",  %{"userName" => userName}
    {:reply, :registered, socket}
  end

  def handle_in("sendtweet_button", params, socket) do
    IO.puts("in tweet channel")
    userName = params["username"]
    tweet = params["tweet"]
    IndividualClient.sendTweet(tweet,userName)
    # GenServer.cast(:server, {:sendTweet, userName, tweet, :os.system_time(:seconds), false, userName})

    push socket, "sendtweet_button",  %{"tweet" => tweet}
    {:reply, :tweetsent, socket}
  end

  def handle_in("subscribe_button", params, socket) do
    IO.puts("in subscribe channel")
    userName = params["username"]
    subTo = params["subscribeTo"]
    IndividualClient.subscribeToUser(userName,subTo)
    # GenServer.call(:server, {:subscribe_oneuser, userName, subTo}, :infinity)
    push socket, "subscribed",  %{"subscribeTo" => subTo}
    {:reply, :subscribed, socket}
  end

  def handle_in("retweet", params, socket) do
    userName = params["username"]
    tweet = params["tweetText"]
    IndividualClient.retweet(userName,tweet)
    # GenServer.cast(:server, {:sendTweet, userName, tweet, :os.system_time(:seconds), true, userName})
    {:noreply, socket}
  end

  def handle_in("search_hashtag", params, socket) do
    hashtag = params["hashtag"]
    # GenServer.call(:server, {:hashtag_query, hashtag})
    IndividualClient.getHashTagTweets(hashtag,self())
    {:noreply, socket}
  end

  def handle_in("search_usermention", params, socket) do
    username = params["username"]
    # GenServer.call(:server, {:usermention_query, username_mention})
    IO.puts(username)
    IndividualClient.getUserMentions(username,self())
    {:noreply, socket}
  end

  def handle_in("search_usertweets", params, socket) do
    username = params["username"]
    # GenServer.call(:server, {:tweets_query, username})
    IndividualClient.getUserTweets(username,self())
    {:noreply, socket}
  end

  def handle_in("start_simulation", _params, socket) do
    sockid = self()
    :global.register_name(:sockid,sockid)
    sid = spawn_link(fn()->PilotCode.pilotMethod() end)
    # GenServer.call(:server, {:simulation}, :infinity)
    {:noreply, socket}
  end

  def handle_info({:hashtag_result, tweetText}, socket) do
    push socket, "search_hashtag", %{"tweet" => tweetText}
    {:noreply, socket}
  end

  def handle_info({:usermention_result, tweetText}, socket) do
    push socket, "usermention", %{"tweet" => tweetText}
    {:noreply, socket}
  end

  def handle_info({:tweetsquery_result, tweetText}, socket) do
    push socket, "tweetsquery", %{"tweet" => tweetText}
    {:noreply, socket}
  end

  def handle_info({:simulation_result, tweetText}, socket) do
    push socket, "print_simulation", %{"tweet" => tweetText}
    {:noreply, socket}
  end

  def handle_info(tweet_text, socket) do
    push socket, "tweet_sub", tweet_text
    {:noreply, socket}
  end

  def insert_into_ets(lookup_table, key, value) do
    :ets.insert(lookup_table, {key, value})
end
end
