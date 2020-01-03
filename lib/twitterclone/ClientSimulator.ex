defmodule ClientSimulator do
    def startClient(numClients,numMsg,parentpid) do
      createUserActors(numClients,numMsg,parentpid)
    end
  
  
    def createUserActors(numClients,numMsg,parentpid) do
      Enum.each(1..numClients,fn(x)->
        userid = "user"<>Integer.to_string(x)
        actorName = String.to_atom(userid)
        Twitter.ClientSimulator.start_link(userid,actorName)
      end)
      send parentpid, {:receivePpid,self()}
      Process.sleep(2000)
      startAutomateProcess(numClients,numMsg,parentpid)
    end
  
  
    def startAutomateProcess(numClients,numMsg,parentpid) do
      usersList = elem(Enum.at(:ets.lookup(:allUsers,:allUsers),0),1)
      # usersList = Enum.to_list(1..numClients)
      # usersList = Enum.map(usersList,fn(x)->
      #   "user"<>Integer.to_string(x)
      # end)
      usersTweetsCount = Enum.map(usersList,fn(x)->
        [x,0]
      end)
      usersOfflineCount =  usersTweetsCount |> Map.new(fn [k, v] -> {k, 0} end)
  
      usersTweetsCount =  usersTweetsCount |> Map.new(fn [k, v] -> {k, v} end)
  
      totalTweets = length(usersList)*numMsg
  
      subscribeToPid = subscribeTo(usersList)
  
      subscribersPid = getSubscribers(usersList)
  
      getsubscribedToPid = getSubscribedTo(usersList)
  
      tweetsPid = spawn_link(fn() -> rollOutTweets(usersTweetsCount,0,totalTweets,numMsg,parentpid) end)
  
      hashtagsPid = spawn_link(fn() -> getHashtags(usersOfflineCount) end)
  
      mentionedTweetsPid = spawn_link(fn() -> getMentionedTweets(usersOfflineCount) end)
  
      userTweetsPid = spawn_link(fn() -> getUserTweets(usersOfflineCount) end)
  
      makeUserOffline = spawn_link(fn() -> makeUserOffline(usersOfflineCount) end)
  
      retweet = spawn_link(fn() -> retweet(usersOfflineCount) end)
  
      # send parentpid, {:receiveChildpids,[tweetsPid,hashtagsPid,mentionedTweetsPid,userTweetsPid,subscribeToPid,subscribersPid,getsubscribedToPid,makeUserOffline,makeUserOnline,retweet]}
      receive do
        {_} -> :ok
      end
    end
  
  
    def isUserOnline?(user) do
      usersOnline = elem(Enum.at(:ets.lookup(:usersOnline,:usersOnline),0),1)
      if Enum.member?(usersOnline,user) do
        true
      else
        false
      end
    end
  
    def rollOutTweets(usersTweetsCount, count, totalTweets,numMsg,parentpid) do
      # IO.inspect "rolltweets"
      if count!=totalTweets && map_size(usersTweetsCount)!=0 do
        tweetsList = ["#COP5615isgreat it is a good subject","#HappyBirthday to you","Have a #GoodDay","Hope everyone is doing good"]
        user = usersTweetsCount |> Map.keys() |> Enum.random()
  
        if isUserOnline?(user) do
  
          usersList = elem(Enum.at(:ets.lookup(:allUsers,:allUsers),0),1)
          tweet = Enum.random(tweetsList)
          tweet = if Enum.random(["mentionRandomUser","doNotMentionsRandomUser"])=="mentionRandomUser" do
            tweet = tweet<>" @"<>Enum.random(usersList)
          else
            tweet
          end
          # IO.inspect Process.alive?(Process.whereis(String.to_atom(user)))
          # spawn_link(fn()->Twitter.ClientSimulatorSimulator.sendTweet(String.to_atom(user),tweet) end)
          s_time = System.system_time(:microsecond)
          send :global.whereis_name(:ServerProcess2),{:tweeted,tweet,user,self(),s_time}
          Process.sleep(500)
          {:ok,msgCount} = Map.fetch(usersTweetsCount,user)
          if msgCount+1==numMsg do
            {_,usersTweetsCount} = Map.pop(usersTweetsCount,user)
            rollOutTweets(usersTweetsCount, count+1, totalTweets,numMsg,parentpid)
          else
            usersTweetsCount = Map.update(usersTweetsCount,user,msgCount,&(&1+1))
            rollOutTweets(usersTweetsCount, count+1, totalTweets,numMsg,parentpid)
          end
  
  
  
        else
          rollOutTweets(usersTweetsCount, count, totalTweets,numMsg,parentpid)
        end
      else
        # IO.inspect "rolldone"
        # send parentpid,{:allUsersTweeted}
      end
    end
  
  
    def getHashtags(usersList) do
      if map_size(usersList)!=0 do
        userid = usersList |> Map.keys() |> Enum.random()
        if isUserOnline?(userid) do
          hashtagsList = ["#COP5615isgreat","#HappyBirthday","#GoodDay"]
          Twitter.ClientSimulator.getHashtagTweets(String.to_atom(userid),Enum.random(hashtagsList))
          {:ok,count} = Map.fetch(usersList,userid)
          if count+1==1 do
            {_,usersList} = Map.pop(usersList,userid)
            Process.sleep(2000)
            getHashtags(usersList)
          else
            usersList = Map.update(usersList,userid,count,&(&1+1))
            Process.sleep(2000)
            getHashtags(usersList)
          end
          # Process.sleep(2000)
          # getHashtags(usersList,Enum.random(usersList))
        else
          getHashtags(usersList)
        end
      else
        # IO.inspect "kill1"
        # Process.exit(self(),:kill)
      end
    end
  
  
    def getMentionedTweets(usersList) do
  
      if map_size(usersList)!=0 do
        userid = usersList |> Map.keys() |> Enum.random()
        if isUserOnline?(userid) do
          Twitter.ClientSimulator.getMentionedTweets(String.to_atom(userid),userid)
          {:ok,count} = Map.fetch(usersList,userid)
          if count+1==1 do
            {_,usersList} = Map.pop(usersList,userid)
            Process.sleep(2000)
            getHashtags(usersList)
          else
            usersList = Map.update(usersList,userid,count,&(&1+1))
            Process.sleep(2000)
            getHashtags(usersList)
          end
        else
          getMentionedTweets(usersList)
        end
      else
        # IO.inspect "kill2"
        # Process.exit(self(),:kill)
      end
  
    end
  
  
    def getUserTweets(usersList) do
      if map_size(usersList)!=0 do
        userid = usersList |> Map.keys() |> Enum.random()
        if isUserOnline?(userid) do
          Twitter.ClientSimulator.getUserTweets(String.to_atom(userid),userid)
          {:ok,count} = Map.fetch(usersList,userid)
          if count+1==1 do
            {_,usersList} = Map.pop(usersList,userid)
            Process.sleep(2000)
            getUserTweets(usersList)
          else
            usersList = Map.update(usersList,userid,count,&(&1+1))
            Process.sleep(2000)
            getUserTweets(usersList)
          end
        else
          getUserTweets(usersList)
        end
      else
        # IO.inspect "kill3"
        # Process.exit(self(),:kill)
      end
    end
  
  
    def subscribeTo(usersList) do
      usersList = Enum.shuffle(usersList)
      Enum.each(usersList,fn(x)->
        usersList = usersList -- [x]
        subscribeToList = Enum.take_random(usersList, round(0.2*length(usersList))+1)
        Enum.each(subscribeToList,fn(subscriber)->
          Twitter.ClientSimulator.subscribeTo(String.to_atom(x),x,subscriber)
          # Process.sleep(100)
        end)
  
      end)
    end
  
  
    def getSubscribers(usersList) do
      usersList = Enum.shuffle(usersList)
      Enum.each(usersList,fn(x)->
        Twitter.ClientSimulator.getSubscribers(String.to_atom(x),x)
        # Process.sleep(2000)
      end)
    end
  
  
    def getSubscribedTo(usersList) do
      usersList = Enum.shuffle(usersList)
      Enum.each(usersList,fn(x)->
        Twitter.ClientSimulator.getSubscribedTo(String.to_atom(x),x)
        # Process.sleep(2000)
      end)
    end
  
  
    def makeUserOffline(usersList) do
      if map_size(usersList)!=0 do
        userid = usersList |> Map.keys() |> Enum.random()
        Twitter.ClientSimulator.makeUserOffline(String.to_atom(userid),userid)
        makeUserOnline = spawn_link(fn() -> makeUserOnline(userid) end)
        {:ok,offlineCount} = Map.fetch(usersList,userid)
        if offlineCount+1==2 do
          {_,usersList} = Map.pop(usersList,userid)
          Process.sleep(500)
          makeUserOffline(usersList)
        else
          usersList = Map.update(usersList,userid,offlineCount,&(&1+1))
          Process.sleep(500)
          makeUserOffline(usersList)
        end
      else
        # Process.exit(:global.whereis_name(:offline),:kill)
      end
    end
  
  
    def makeUserOnline(userid) do
      Process.sleep(2000)
      send :global.whereis_name(:ServerProcess2), {:makeUserOnline,userid,self(),:prod}
      # IO.inspect "user online method"
      # userid = Enum.random(usersList)
      # Twitter.ClientSimulator.makeUserOnline(String.to_atom(userid),userid)
      Process.sleep(500)
    end
  
  
    # def retweet(usersList,user) do
    #   if isUserOnline?(user) do
    #     Twitter.ClientSimulator.retweet(String.to_atom(user),user)
    #   end
    #   Process.sleep(2000)
    #   retweet(usersList,Enum.random(usersList))
    # end
  
  
    def retweet(usersList) do
      if map_size(usersList)!=0 do
        userid = usersList |> Map.keys() |> Enum.random()
        if isUserOnline?(userid) do
          Twitter.ClientSimulator.retweet(String.to_atom(userid),userid)
          {:ok,count} = Map.fetch(usersList,userid)
          if count+1==2 do
            {_,usersList} = Map.pop(usersList,userid)
            Process.sleep(2000)
            retweet(usersList)
          else
            usersList = Map.update(usersList,userid,count,&(&1+1))
            Process.sleep(2000)
            retweet(usersList)
          end
        else
          retweet(usersList)
        end
      else
        # IO.inspect "kill7"
        # Process.exit(self(),:kill)
      end
    end
  
  end
  
  
  
  
  defmodule Twitter.ClientSimulator do
    def start_link(userid,actorName) do
      GenServer.start_link(__MODULE__,userid,name: actorName)
    end
  
  
    def init(userid) do
      :global.sync()
      {:ok,ip_list}=:inet.getif()
      ip_address = elem(Enum.at(ip_list,0),0)
      clientNodeName = String.to_atom("client@"<>to_string(:inet_parse.ntoa(ip_address)))
    #   Node.start(clientNodeName)
    #   Node.set_cookie(clientNodeName,:twitter)
    #   Node.connect(String.to_atom("server@" <> to_string(:inet_parse.ntoa(ip_address))))
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2),{:registerNewUser,userid,self()}
      sockid = :global.whereis_name(:sockid)
      IO.inspect sockid
      receive do
        {:registrationDone} -> send sockid, {:simulation_result,"#{userid} registered"}
      end
      tot_time = System.system_time(:microsecond) - s_time
      # IO.inspect tot_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,0)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,0,innerList)
      :ets.insert(:time,{:timeList,timeList})
      # IO.inspect elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      {:ok,userid}
    end
  
  
    def sendTweet(actorName,tweet) do
      IO.inspect Process.alive?(Process.whereis(actorName))
      GenServer.cast(actorName,{:sendTweet,tweet})
    end
  
  
    def getHashtagTweets(actorName,hashtag) do
      GenServer.cast(actorName,{:getHashtagTweets,hashtag})
    end
  
  
    def getMentionedTweets(actorName, userid) do
      GenServer.cast(actorName,{:getMentionedTweets,userid})
    end
  
  
    def getUserTweets(actorName, userid) do
      GenServer.cast(actorName,{:getUserTweets,userid})
    end
  
  
    def subscribeTo(actorName,userid,subscribeToList) do
      GenServer.cast(actorName,{:subscribeTo,userid,subscribeToList})
    end
  
  
    def getSubscribers(actorName,userid) do
      GenServer.cast(actorName,{:getSubscribers,userid})
    end
  
  
    def getSubscribedTo(actorName,userid) do
      GenServer.cast(actorName,{:getSubscribedTo,userid})
    end
  
  
    def makeUserOffline(actorName, userid) do
      GenServer.cast(actorName,{:makeUserOffline,userid})
    end
  
  
    def makeUserOnline(actorName, userid) do
      GenServer.cast(actorName,{:makeUserOnline,userid})
    end
  
  
    def retweet(actorName,userid) do
      GenServer.cast(actorName,{:retweet,userid})
    end
  
    def handle_cast({:retweet,userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2), {:retweet,userid,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:retweeted,message} -> send sockid, {:simulation_result,message}
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,8)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,8,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:makeUserOnline,userid},userid) do
      send :global.whereis_name(:ServerProcess2) ,{:makeUserOnline,self(),:prod}
      {:noreply,userid}
    end
  
  
    def handle_cast({:makeUserOffline,userid},userid) do
      send :global.whereis_name(:ServerProcess2) ,{:makeUserOffline,userid,self(),:prod}
      {:noreply,userid}
    end
  
  
    def handle_cast({:getSubscribedTo,userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2) ,{:getSubscribedTo,userid,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:receiveSubscribedToList,subscribedToList} -> Enum.each(subscribedToList,fn(x)->
            send sockid, {:simulation_result,"#{x} is in #{userid} subscribed list"}
        end)
            
        # {:receiveSubscribedToList,subscribedToList} -> IO.puts(["------------#{userid} subscribed to all the following users\n",Enum.join(subscribedToList,"\n")])
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,7)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,7,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:getSubscribers,userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2) ,{:getSubscribers,userid,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        
        {:receiveSubscribersList,subscribersList} -> Enum.each(subscribersList,fn(x)->
            send sockid, {:simulation_result,"#{userid}\'s subscriber is #{x}"}
        end)
            # IO.puts(["------------#{userid}\'s subscribers are: \n",Enum.join(subscribersList,"\n")])
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,6)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,6,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:subscribeTo,userid,subscribeToList},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2) ,{:subscribeToUser,userid,subscribeToList,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:receiveSubscriptionConfirmation,subscriberid} -> send sockid, {:simulation_result,"#{userid} subscribed to #{subscriberid}"}
            # IO.puts("#{userid} subscribed to #{subscriberid}\n")
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,5)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,5,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:getUserTweets,userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2) ,{:getUserTweets,userid,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:receiveUserTweets,tweetsList} -> send sockid, {:simulation_result,"#{userid} tweets are:#{inspect tweetsList}"}
            # IO.puts(["-------- #{userid} requested for own tweets ---------\n", Enum.join(tweetsList, "\n")])
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,4)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,4,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:getMentionedTweets, userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2) ,{:getMentionedTweets,userid,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:receiveMentionedTweets,tweetsList} -> tweetsList = Enum.map(tweetsList,fn(x)->
                                                              Enum.join(x," by ")
                                                            end)
                                                            send sockid, {:simulation_result,"#{userid} mentioned tweets are #{inspect tweetsList}"}
                                                            #   IO.puts(["-------- #{userid} requested for mentioned tweets ---------\n", Enum.join(tweetsList, "\n")])
      end
      tot_time = System.system_time(:microsecond) - s_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,3)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,3,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:getHashtagTweets,hashtag},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess2),{:getHashtagTweets,hashtag,self()}
      sockid = :global.whereis_name(:sockid)
      receive do
        {:receiveHashtagTweets,tweetsList} -> tweetsList = Enum.map(tweetsList,fn(x)->
                                                              Enum.join(x," by ")
                                                            end)
                                                            send sockid, {:simulation_result,"#{userid} requested for tweets with #{hashtag} #{inspect tweetsList}"}
                                                            #   IO.puts(["-------- #{userid} requested for tweets with hashtag #{hashtag} ---------\n", Enum.join(tweetsList, "\n")])
      end
      tot_time = System.system_time(:microsecond) - s_time
      # IO.inspect tot_time
      timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
      innerList = Enum.at(timeList,2)
      innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
      innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
      timeList = List.replace_at(timeList,2,innerList)
      :ets.insert(:time,{:timeList,timeList})
      {:noreply,userid}
    end
  
  
    def handle_cast({:sendTweet,tweet},userid) do
      # IO.inspect "bow"
      send :global.whereis_name(:ServerProcess2),{:tweeted,tweet,userid,self(),:prod}
      # receive do
      #   {:userTweeted,tweet} -> IO.inspect tweet
      # end
      {:noreply,userid}
    end
  
  end
  