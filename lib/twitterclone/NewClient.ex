defmodule IndividualClient do
    def createActor(x,socpid) do
        userid = "user"<>x
        actorName = String.to_atom(userid)
        Twitter.Client.start_link(userid,socpid,actorName)
        IO.inspect Process.alive?(Process.whereis(actorName))
    end

    def sendTweet(tweet,x) do
        userid = "user"<>x
        actorName = String.to_atom(userid)
        Twitter.Client.sendTweet(actorName,tweet)
    end

    def subscribeToUser(x,y) do
        userid = "user"<>x
        subid = "user"<>y
        Twitter.Client.subscribeTo(String.to_atom(userid),userid,subid)
    end

    def getHashTagTweets(hashtag,channelpid) do
        hashtag="#"<>hashtag
        send :global.whereis_name(:ServerProcess),{:getHashtagTweets,hashtag,self()}
      receive do
        {:receiveHashtagTweets,tweetsList} -> Enum.each(tweetsList,fn(x)->
                                                send channelpid, {:hashtag_result, x}
                                                end)
        end
    end

    def getUserMentions(userid,channelpid) do
        username = "user"<>userid
        send :global.whereis_name(:ServerProcess) ,{:getMentionedTweets,username,self()}
        receive do
            {:receiveMentionedTweets,tweetsList} -> Enum.each(tweetsList,fn(x)->
                                                        send channelpid, {:usermention_result, x}
                                                    end)
                                                    
        end
    end

    def getUserTweets(userid,channelpid) do
        userid = "user"<>userid
        send :global.whereis_name(:ServerProcess) ,{:getUserTweets,userid,self()}
      receive do
        {:receiveUserTweets,tweetsList} -> Enum.each(tweetsList,fn(x)->
                                                send channelpid, {:tweetsquery_result, x}
                                            end)
      end
    end

    def retweet(userid,tweet) do
        sockpid = elem(Enum.at(:ets.lookup(:usersSock,"user"<>userid),0),1)
        send sockpid, %{"tweetText" => tweet, "nodeid" => userid}
    end
end

  
  
  
  
  defmodule Twitter.Client do
    def start_link(userid,socpid,actorName) do
      GenServer.start_link(__MODULE__, [userid,socpid], name: actorName)
    end
  
  
    def init([userid,socpid]) do
      :global.sync()
      {:ok,ip_list}=:inet.getif()
      ip_address = elem(Enum.at(ip_list,0),0)
      clientNodeName = String.to_atom("client@"<>to_string(:inet_parse.ntoa(ip_address)))
    #   Node.start(clientNodeName)
    #   Node.set_cookie(clientNodeName,:twitter)
    #   Node.connect(String.to_atom("server@" <> to_string(:inet_parse.ntoa(ip_address))))
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess),{:registerNewUser,userid,self()}
      receive do
        {:registrationDone} -> IO.puts("#{userid} registered")
      end
      :ets.insert(:usersSock,{userid,socpid})
      
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
  
  
    def subscribeTo(actorName,userid,subscribeTo) do
      GenServer.cast(actorName,{:subscribeTo,userid,subscribeTo})
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
      send :global.whereis_name(:ServerProcess), {:retweet,userid,self()}
      receive do
        {:retweeted,message} -> IO.puts(message)
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
      send :global.whereis_name(:ServerProcess) ,{:makeUserOnline,self(),:prod}
      {:noreply,userid}
    end
  
  
    def handle_cast({:makeUserOffline,userid},userid) do
      send :global.whereis_name(:ServerProcess) ,{:makeUserOffline,userid,self(),:prod}
      {:noreply,userid}
    end
  
  
    def handle_cast({:getSubscribedTo,userid},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess) ,{:getSubscribedTo,userid,self()}
      receive do
        {:receiveSubscribedToList,subscribedToList} -> IO.puts(["------------#{userid} subscribed to all the following users\n",Enum.join(subscribedToList,"\n")])
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
      send :global.whereis_name(:ServerProcess) ,{:getSubscribers,userid,self()}
      receive do
        {:receiveSubscribersList,subscribersList} -> IO.puts(["------------#{userid}\'s subscribers are: \n",Enum.join(subscribersList,"\n")])
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
  
  
    def handle_cast({:subscribeTo,userid,subscribeTo},userid) do
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess) ,{:subscribeToUser,userid,subscribeTo,self()}
      receive do
        {:receiveSubscriptionConfirmation,subscriberid} -> IO.puts("#{userid} subscribed to #{subscriberid}\n")
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
      send :global.whereis_name(:ServerProcess) ,{:getUserTweets,userid,self()}
      receive do
        {:receiveUserTweets,tweetsList} -> IO.puts(["-------- #{userid} requested for own tweets ---------\n", Enum.join(tweetsList, "\n")])
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
      send :global.whereis_name(:ServerProcess) ,{:getMentionedTweets,userid,self()}
      receive do
        {:receiveMentionedTweets,tweetsList} -> tweetsList = Enum.map(tweetsList,fn(x)->
                                                              Enum.join(x," by ")
                                                            end)
                                                              IO.puts(["-------- #{userid} requested for mentioned tweets ---------\n", Enum.join(tweetsList, "\n")])
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
      send :global.whereis_name(:ServerProcess),{:getHashtagTweets,hashtag,self()}
      receive do
        {:receiveHashtagTweets,tweetsList} -> tweetsList = Enum.map(tweetsList,fn(x)->
                                                              Enum.join(x," by ")
                                                            end)
                                                              IO.puts(["-------- #{userid} requested for tweets with hashtag #{hashtag} ---------\n", Enum.join(tweetsList, "\n")])
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
      s_time = System.system_time(:microsecond)
      send :global.whereis_name(:ServerProcess),{:tweeted,tweet,userid,self(),s_time}
      # receive do
      #   {:userTweeted,tweet} -> IO.inspect tweet
      # end
      {:noreply,userid}
    end
  
  end
  