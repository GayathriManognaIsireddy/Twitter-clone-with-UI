defmodule PilotCode do
    @moduledoc """
    Documentation for Proj4.
    """
  
    @doc """
    Hello world.
  
    ## Examples
  
        iex> Proj4.hello()
        :world
  
    """
    def pilotMethod() do
      numClients = 100
      numMsg=2
      
      ServerSimulator.startServer(numClients*numMsg)
      Process.sleep(2000)
  
      pid = self()
      :global.register_name(:pilotProc,pid)
      Task.start(fn() -> ClientSimulator.startClient(numClients,numMsg,pid) end)
      receive do
        {:receivePpid,ppid} -> waitForChildren(ppid)
      end
      IO.inspect "Process completed"
      # receive do
      #   {_} -> :ok
      # end
    end
  
  
    def waitForChildren(ppid) do
      receive do
        {:allUsersTweeted} ->   IO.inspect "All users tweeted"
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),0)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
        IO.puts("Average time taken to register user: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),1)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken by the user to tweet: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),2)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to get tweets with a specific hashtag: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),3)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to get mentioned tweets: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),4)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to get tweets of user: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),5)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to subscribe to an user: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),6)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to get subscribers of user: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),7)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to get the users that an user has subscribed to: #{val} us")
        end
  
  
        list = Enum.at(elem(Enum.at(:ets.lookup(:time,:timeList),0),1),8)
        if Enum.at(list,0)!=0 do
          val = Enum.at(list,1)/Enum.at(list,0)
          IO.puts("Average time taken to retweet: #{val} us")
        end
  
                                # if Process.alive?(self()) do
                                #   Process.exit(self(),:kill)
                                # end
  
      end
    end
  
  
    def handle_args(args) do
      numClients = String.to_integer(Enum.at(args,0))
      numMsg = String.to_integer(Enum.at(args,1))
      {numClients,numMsg}
    end
  end
  