defmodule ServerSimulator do
    def startServer(totalTweets) do
        
      Task.start(fn -> Twitter.ServerSimulator.start_link(totalTweets) end)
      # receive do
      #   {_} -> :ok
      # end
    end
  end
  
  defmodule Twitter.ServerSimulator do
    def start_link(totalTweets) do
      GenServer.start_link(__MODULE__, totalTweets)
    end
  
  
    def init(totalTweets) do
      {:ok,ip_list}=:inet.getif()
      ip_address = elem(Enum.at(ip_list,0),0)
      serverNodeName = String.to_atom("server@"<>to_string(:inet_parse.ntoa(ip_address)))
  
    #   Node.start(serverNodeName)
    #   Node.set_cookie(serverNodeName,:twitter)
    
      initialize_tables(totalTweets)
      IO.puts("IN simulation")
      serverpid = spawn_link(fn() -> startProcess() end)
      
      :global.register_name(:ServerProcess2,serverpid)
      IO.puts("Server is up and running..................")
      receive do: (_ -> :ok)
    end
  
  
    def initialize_tables(totalTweets) do
  
    #   :ets.new(:users, [:set, :public, :named_table])
    #   :ets.new(:allUsers,[:set, :public, :named_table])
    #   :ets.insert(:allUsers,{:allUsers,[]})
    #   :ets.new(:usersOnline,[:set, :public, :named_table])
    #   :ets.insert(:usersOnline,{:usersOnline,[]})
    #   :ets.new(:usersOffline,[:set, :public, :named_table])
    #   :ets.insert(:usersOffline,{:usersOffline,[]})
    #   :ets.new(:tweets, [:set, :public, :named_table])
    #   :ets.new(:hashtags, [:set, :public, :named_table])
    #   :ets.new(:mentions, [:set, :public, :named_table])
    #   :ets.new(:userSubscribedTo, [:set, :public, :named_table])
    #   :ets.new(:subscribers, [:set, :public, :named_table])
    #   :ets.new(:retweets, [:set, :public, :named_table])
    #   :ets.new(:liveTweetsToUser, [:set, :public, :named_table])
    #   :ets.new(:tweetsCount,[:set, :public, :named_table])
    #   :ets.insert(:tweetsCount,{:tweetsCount,[0,totalTweets]})
    #   :ets.new(:time,[:set, :public, :named_table])
    #   :ets.insert(:time,{:timeList,[[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]})
  
    end
  
  
    def startProcess() do
      receive do
        {:registerNewUser,userid,pid} -> registerUser(userid,pid)
        {:tweeted,tweet,userid,userpid,env} -> tweetHandle(tweet,userid,userpid,env)
        {:getHashtagTweets,hashtag,userpid} -> getHashtagTweets(hashtag,userpid)
        {:getMentionedTweets,userid,userpid} -> getMentionedTweets(userid,userpid)
        {:getUserTweets,userid,userpid} -> getUserTweets(userid,userpid)
        {:subscribeToUser,userid,subscribeid,userpid} -> addSubscribeTo(userid,subscribeid)
                                                 addSubscribers(subscribeid,userid,userpid)
        {:getSubscribers,userid,userpid} -> getSubscribers(userid,userpid)
        {:getSubscribedTo,userid,userpid} -> getSubscribedTo(userid,userpid)
        {:makeUserOffline,userid,userpid,env} -> makeUserOffline(userid,userpid,env)
        {:makeUserOnline,userid,userpid,env} -> makeUserOnline(userid,userpid,env)
        {:retweet,userid,userpid} -> retweet(userid,userpid)
        {:deleteAccount,userid,userpid} -> deleteAccount(userid,userpid)
      end
      startProcess()
    end
  
  
    def registerUser(userid,pid) do
      if :ets.lookup(:users,userid)==[] do
        :ets.insert(:users,{userid,pid})
        :ets.insert(:tweets,{userid,[]})
        :ets.insert(:retweets,{userid,[]})
        :ets.insert(:liveTweetsToUser,{userid,[]})
        :ets.insert(:subscribers,{userid,[]})
        usersOnline = elem(Enum.at(:ets.lookup(:usersOnline,:usersOnline),0),1)
        usersOnline = [userid] ++ usersOnline
        :ets.insert(:usersOnline,{:usersOnline,usersOnline})
        allUsers = elem(Enum.at(:ets.lookup(:allUsers,:allUsers),0),1)
        allUsers = [userid] ++ allUsers
        :ets.insert(:allUsers,{:allUsers,allUsers})
  
        send(pid,{:registrationDone})
      else
        send(pid,{:userAlreadyRegistered})
      end
    end
  
  
    def tweetHandle(tweet,userid,userpid,env) do
        sockid = :global.whereis_name(:sockid)
        send sockid, {:simulation_result,"Live tweet ----> #{userid} tweeted: #{tweet}"}
    #   IO.puts("Live tweet ----> #{userid} tweeted: #{tweet}")
      tweetsCount = elem(Enum.at(:ets.lookup(:tweetsCount,:tweetsCount),0),1)
      count = Enum.at(tweetsCount,0)
      tweetsCount = Enum.at(tweetsCount,1)
      count=count+1
      if count==tweetsCount do
        send :global.whereis_name(:pilotProc), {:allUsersTweeted}
      end
      :ets.insert(:tweetsCount,{:tweetsCount,[count,tweetsCount]})
      hashtags = Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweet)
      hashtags = List.flatten(hashtags)
      Enum.each(hashtags,fn(x)->
        handleHashtags(x,tweet,userid)
      end)
      mentions = Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweet)
      mentions = List.flatten(mentions)
      Enum.each(mentions,fn(x)->
        handleMentions(x,tweet,userid)
      end)
      tweetsList = elem(Enum.at(:ets.lookup(:tweets,userid),0),1)
      tweetsList = [tweet] ++ tweetsList
      :ets.insert(:tweets,{userid,tweetsList})
  
      list = elem(Enum.at(:ets.lookup(:subscribers,userid),0),1)
      Enum.each(list,fn(x)->
        if isUserOnline?(x) do
          list = elem(Enum.at(:ets.lookup(:liveTweetsToUser,x),0),1)
          list = [[tweet,userid]] ++ list
          :ets.insert(:liveTweetsToUser,{x,list})
        end
      end)
      if env==:test do
        send userpid, {:userTweeted,tweet}
      else
        tot_time = System.system_time(:microsecond) - env
        # IO.inspect tot_time
        timeList = elem(Enum.at(:ets.lookup(:time,:timeList),0),1)
        innerList = Enum.at(timeList,0)
        innerList = List.replace_at(innerList,0,Enum.at(innerList,0)+1)
        innerList = List.replace_at(innerList,1,Enum.at(innerList,1)+tot_time)
        timeList = List.replace_at(timeList,1,innerList)
        :ets.insert(:time,{:timeList,timeList})
      end
  
    end
  
  
    def handleHashtags(hashtag,tweet,userid) do
      if :ets.lookup(:hashtags,hashtag)==[] do
        :ets.insert(:hashtags,{hashtag,[[tweet,userid]]})
      else
        tweets = elem(Enum.at(:ets.lookup(:hashtags,hashtag),0),1)
        tweets = [[tweet,userid]] ++ tweets
        :ets.insert(:hashtags,{hashtag,tweets})
      end
    end
  
  
    def handleMentions(mention,tweet,userid) do
      if :ets.lookup(:mentions,mention)==[] do
        :ets.insert(:mentions,{mention,[[tweet,userid]]})
      else
        tweets = elem(Enum.at(:ets.lookup(:mentions,mention),0),1)
        tweets = [[tweet,userid]] ++ tweets
        :ets.insert(:mentions,{mention,tweets})
      end
      if isUserOnline?(userid) do
        uid = Enum.at(String.split(mention,"@"),1)
        list = elem(Enum.at(:ets.lookup(:liveTweetsToUser,uid),0),1)
        list = [[tweet,userid]] ++ list
        :ets.insert(:liveTweetsToUser,{mention,list})
      end
    end
  
  
    def isUserOnline?(userid) do
      usersOnline = elem(Enum.at(:ets.lookup(:usersOnline,:usersOnline),0),1)
      if Enum.member?(usersOnline,userid) do
        true
      else
        false
      end
    end
  
  
    def getHashtagTweets(hashtag,userpid) do
      list = :ets.lookup(:hashtags,hashtag)
      tweetsList = if list == [] do
        []
      else
        elem(Enum.at(list,0),1)
      end
  
        send userpid, {:receiveHashtagTweets,tweetsList}
  
  
    end
  
  
    def getMentionedTweets(userid, userpid) do
      userid = "@"<>userid
      list = :ets.lookup(:mentions,userid)
      tweetsList = if list == [] do
        []
      else
        elem(Enum.at(list,0),1)
      end
      send userpid, {:receiveMentionedTweets,tweetsList}
    end
  
  
    def getUserTweets(userid,userpid) do
      tweetsList = elem(Enum.at(:ets.lookup(:tweets,userid),0),1)
  
      send userpid, {:receiveUserTweets,tweetsList}
    end
  
  
    def addSubscribeTo(userid,subscribeid) do
      if :ets.lookup(:userSubscribedTo,userid)==[] do
        :ets.insert(:userSubscribedTo,{userid,[subscribeid]})
      else
        userSubscribedTo = elem(Enum.at(:ets.lookup(:userSubscribedTo,userid),0),1)
        userSubscribedTo = [subscribeid] ++ userSubscribedTo
        :ets.insert(:userSubscribedTo,{userid,userSubscribedTo})
      end
    end
  
  
    def addSubscribers(subscriberid,userid,userpid) do
      if :ets.lookup(:subscribers,subscriberid)==[] do
        :ets.insert(:subscribers,{subscriberid,[userid]})
      else
        subscribers = elem(Enum.at(:ets.lookup(:subscribers,subscriberid),0),1)
        subscribers = [userid] ++ subscribers
        :ets.insert(:subscribers,{subscriberid,subscribers})
      end
      send userpid, {:receiveSubscriptionConfirmation,subscriberid}
    end
  
  
    def getSubscribers(userid,userpid) do
      list = :ets.lookup(:subscribers,userid)
      subscribersList = if list == [] do
        []
      else
        elem(Enum.at(list,0),1)
      end
      send userpid, {:receiveSubscribersList,subscribersList}
    end
  
  
    def getSubscribedTo(userid,userpid) do
      list = :ets.lookup(:userSubscribedTo,userid)
      subscribedToList = if list == [] do
        []
      else
        elem(Enum.at(list,0),1)
      end
      send userpid, {:receiveSubscribedToList,subscribedToList}
    end
  
  
    def makeUserOffline(userid,userpid,env) do
      usersOffline = elem(Enum.at(:ets.lookup(:usersOffline,:usersOffline),0),1)
      sockid = :global.whereis_name(:sockid)
      if !Enum.member?(usersOffline,userid) do
        send sockid, {:simulation_result,"#{userid} went offline"}
        # IO.puts("#{userid} went offline")
      end
      usersOffline = [userid] ++ usersOffline
      usersOffline = Enum.uniq(usersOffline)
      :ets.insert(:usersOffline,{:usersOffline,usersOffline})
  
      usersOnline = elem(Enum.at(:ets.lookup(:usersOnline,:usersOnline),0),1)
      usersOnline = if Enum.member?(usersOnline,userid) do
        usersOnline = usersOnline -- [userid]
        usersOnline
      else
        usersOnline
      end
      usersOnline = Enum.uniq(usersOnline)
      :ets.insert(:usersOnline,{:usersOnline,usersOnline})
      if env==:test do
        send userpid, {:userWentOffline}
      end
    end
  
  
    def makeUserOnline(userid,userpid,env) do
      usersOnline = elem(Enum.at(:ets.lookup(:usersOnline,:usersOnline),0),1)
      usersOffline = elem(Enum.at(:ets.lookup(:usersOffline,:usersOffline),0),1)
      sockid = :global.whereis_name(:sockid)
      if length(usersOffline)!=0 do
        if !Enum.member?(usersOnline,userid) do
        send sockid, {:simulation_result,"#{userid} came online"}
        #   IO.puts("#{userid} came online")
        end
        usersOnline = [userid] ++ usersOnline
        usersOnline = Enum.uniq(usersOnline)
        :ets.insert(:usersOnline,{:usersOnline,usersOnline})
  
        usersOffline = elem(Enum.at(:ets.lookup(:usersOffline,:usersOffline),0),1)
        usersOffline = if Enum.member?(usersOffline,userid) do
          usersOffline = usersOffline -- [userid]
          usersOffline
        else
          usersOffline
        end
        usersOffline = Enum.uniq(usersOffline)
        :ets.insert(:usersOffline,{:usersOffline,usersOffline})
      end
      if env==:test do
        send userpid, {:userCameOnline}
      end
    end
  
  
    def retweet(userid,userpid) do
      list = :ets.lookup(:userSubscribedTo,userid)
      subscribedTo = if list==[] do
        []
      else
        elem(Enum.at(list,0),1)
      end
      if length(subscribedTo)!=0 do
        s_userid = Enum.random(subscribedTo)
        tweets = :ets.lookup(:tweets,s_userid)
        tweets = if tweets!=[] do
          elem(Enum.at(tweets,0),1)
        else
          []
        end
        sockid = :global.whereis_name(:sockid)
        if length(tweets)!=0 do
          tweet = Enum.random(tweets)
          list = elem(Enum.at(:ets.lookup(:retweets,userid),0),1)
          list = [[tweet,s_userid]] ++ list
          :ets.insert(:retweets,{userid,list})
        #   send sockid, {:simulation_result,"#{userid} retweeted #{s_userid}\'s tweet: #{tweet}"}
        send userpid, {:retweeted,"#{userid} retweeted #{s_userid}\'s tweet: #{tweet}"}
        end
      end
    end
  
  
    def deleteAccount(userid,userpid) do
  
      :ets.delete(:users, userid)
      :ets.delete(:tweets, userid)
      :ets.delete(:mentions, userid)
      :ets.delete(:userSubscribedTo, userid)
      :ets.delete(:subscribers, userid)
      :ets.delete(:retweets, userid)
      :ets.delete(:liveTweetsToUser, userid)
      send userpid, {:accountDeleted}
    end
  
  
  end
  