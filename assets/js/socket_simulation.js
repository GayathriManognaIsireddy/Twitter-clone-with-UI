import {Socket} from "phoenix"

let channel

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
channel = socket.channel("twitterChannel:lobby", {})

//join the new client
channel.join()
.receive("ok", resp => { console.log("Joined successfully in simulation", resp) })
.receive("error", resp => { console.log("Unable to join in simulation", resp) })

let messageContainer = document.querySelector('#tweets')


document.getElementById('simulation_button').onclick = function () {
    console.log("here in simulation onclick")
    channel.push("start_simulation", {time: `${Date()}`})
   }

channel.on("print_simulation", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `simulation messages:  ${payload.tweet}`
    messageContainer.appendChild(messageItem)
  })