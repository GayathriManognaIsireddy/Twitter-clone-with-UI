defmodule Proj4Test do
  use ExUnit.Case, async: false
  doctest Twitter.Server
  use GenServer

  setup_all do
    {:ok,server_pid} = Task.start(fn()-> Twitter.Server.start_link(1000) end)
    Process.sleep(2000)
    # IO.inspect :global.registered_names()
    {:ok,server: server_pid}

  end

  test "register user 1" do
    IO.inspect "test1"
    send :global.whereis_name(:ServerProcess), {:registerNewUser,"user1",self()}
    Process.sleep(500)
    assert_received {:registrationDone}, 5000
  end

  test "register user 2" do
    IO.inspect "test2"
    send :global.whereis_name(:ServerProcess), {:registerNewUser,"user2",self()}
    Process.sleep(500)
    assert_received {:registrationDone}, 5000
  end

  test "register user 3" do
    IO.inspect "test3"
    send :global.whereis_name(:ServerProcess), {:registerNewUser,"user3",self()}
    Process.sleep(500)
    assert_received {:registrationDone}, 5000
  end

  test "register user again" do
    IO.inspect "test4"
    send :global.whereis_name(:ServerProcess), {:registerNewUser,"user1",self()}
    Process.sleep(500)
    assert_received {:userAlreadyRegistered}, 5000
  end

  test "user tweeted" do
    IO.inspect "test5"
    send :global.whereis_name(:ServerProcess), {:tweeted,"#HappyBirthday to you @user2","user1",self(),:test}
    Process.sleep(500)
    assert_received {:userTweeted,"#HappyBirthday to you @user2"}, 5000
  end

  test "get hashtags" do
    IO.inspect "test6"
    send :global.whereis_name(:ServerProcess), {:getHashtagTweets,"#HappyBirthday",self()}
    Process.sleep(500)
    assert_received {:receiveHashtagTweets,[["#HappyBirthday to you @user2","user1"]]}, 5000
  end

  test "get hashtags not found" do
    IO.inspect "test7"
    send :global.whereis_name(:ServerProcess), {:getHashtagTweets,"#booboo",self()}
    Process.sleep(500)
    assert_received {:receiveHashtagTweets,[]}, 5000
  end

  test "get mentions" do
    IO.inspect "test8"
    send :global.whereis_name(:ServerProcess), {:getMentionedTweets,"user2",self()}
    Process.sleep(500)
    assert_received {:receiveMentionedTweets,[["#HappyBirthday to you @user2","user1"]]}, 5000
  end

  test "get mentions not found" do
    IO.inspect "test9"
    send :global.whereis_name(:ServerProcess), {:getMentionedTweets,"user3",self()}
    Process.sleep(500)
    assert_received {:receiveMentionedTweets,[]}, 5000
  end

  test "get user tweets" do
    IO.inspect "test10"
    send :global.whereis_name(:ServerProcess), {:getUserTweets,"user1",self()}
    Process.sleep(500)
    assert_received {:receiveUserTweets,["#HappyBirthday to you @user2"]}, 5000
  end

  test "get user tweets not found" do
    IO.inspect "test11"
    send :global.whereis_name(:ServerProcess), {:getUserTweets,"user2",self()}
    Process.sleep(500)
    assert_received {:receiveUserTweets,[]}, 5000
  end

  test "subscribe to user" do
    IO.inspect "test12"
    send :global.whereis_name(:ServerProcess), {:subscribeToUser,"user1","user2",self()}
    Process.sleep(500)
    assert_received {:receiveSubscriptionConfirmation,"user2"}, 5000
  end

  test "get subscribers of user" do
    IO.inspect "test13"
    send :global.whereis_name(:ServerProcess), {:getSubscribers,"user2",self()}
    Process.sleep(500)
    assert_received {:receiveSubscribersList,["user1"]}, 5000
  end

  test "get empty subscribers of user" do
    IO.inspect "test14"
    send :global.whereis_name(:ServerProcess), {:getSubscribers,"user1",self()}
    Process.sleep(500)
    assert_received {:receiveSubscribersList,[]}, 5000
  end

  test "get users subscribed to" do
    IO.inspect "test15"
    send :global.whereis_name(:ServerProcess), {:getSubscribedTo,"user1",self()}
    Process.sleep(500)
    assert_received {:receiveSubscribedToList,["user2"]}, 5000
  end

  test "get empty users subscribed to" do
    IO.inspect "test16"
    send :global.whereis_name(:ServerProcess), {:getSubscribedTo,"user2",self()}
    Process.sleep(500)
    assert_received {:receiveSubscribedToList,[]}, 5000
  end

  test "make user offline" do
    IO.inspect "test17"
    send :global.whereis_name(:ServerProcess), {:makeUserOffline,"user1",self(),:test}
    Process.sleep(500)
    assert_received {:userWentOffline}, 5000
  end

  test "make user online" do
    IO.inspect "test18"
    send :global.whereis_name(:ServerProcess), {:makeUserOnline,"user1",self(),:test}
    Process.sleep(500)
    assert_received {:userCameOnline}, 5000
  end

  test "user2 tweeted" do
    IO.inspect "test19"
    send :global.whereis_name(:ServerProcess), {:tweeted,"How are you all?","user2",self(),:test}
    Process.sleep(500)
    assert_received {:userTweeted,"How are you all?"}, 5000
  end

  test "user retweeted" do
    IO.inspect "test20"
    send :global.whereis_name(:ServerProcess), {:retweet,"user1",self()}
    Process.sleep(500)
    assert_received {:retweeted,"user1 retweeted user2's tweet: How are you all?"}, 5000
  end

  test "delete user" do
    IO.inspect "test21"
    send :global.whereis_name(:ServerProcess), {:deleteAccount,"user1",self()}
    Process.sleep(500)
    assert_received {:accountDeleted}, 5000
  end

end
