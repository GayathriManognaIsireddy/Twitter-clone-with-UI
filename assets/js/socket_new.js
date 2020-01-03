import {Socket} from "phoenix"

let channel

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
channel = socket.channel("twitterChannel:lobby", {})

//join the new client
channel.join()
.receive("ok", resp => { console.log("Joined successfully", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

let username = document.querySelector('#username')
let tweet = document.querySelector('#sendtweet')
let subscribeTo = document.querySelector('#subscribe')
let hashtag = document.querySelector('#search_hashtag')
let msgDiv = document.querySelector('#messages')

document.getElementById('username_button').onclick = function () {
    channel.push("username_button", {username: username.value, time: `${Date()}`})
    .receive("registered" , resp => console.log("registered", resp))
    let messageItem = document.createElement("li");
    messageItem.innerText = `${username.value} registered and logged in`
    msgDiv.appendChild(messageItem)
   }

document.getElementById('logout_button').onclick = function () {
    channel.push("logout_button", {username: username.value, time: `${Date()}`})
    let messageItem = document.createElement("li");
    messageItem.innerText = `${username.value} logged out`
    window.alert("Bye-Bye, you are logged out!");
    msgDiv.appendChild(messageItem)
   }

document.getElementById('login_button').onclick = function () {
    channel.push("username_button", {username: username.value, time: `${Date()}`})
    .receive("registered" , resp => console.log("registered", resp))
    let messageItem = document.createElement("li");
    messageItem.innerText = `${username.value} logged in`
    window.alert("Welcome back!");
    msgDiv.appendChild(messageItem)
   }
   
document.getElementById('sendtweet_button').onclick = function () {
    channel.push("sendtweet_button", {tweet: tweet.value, username: username.value, time: `${Date()}`})
    .receive("sendtweet_button" , resp => console.log("tweetsent", resp))
    let messageItem = document.createElement("li");
    messageItem.innerText = `${username.value} tweeted ${tweet.value}`
    msgDiv.appendChild(messageItem)
   }

document.getElementById('subscribe_button').onclick = function () {
    channel.push("subscribe_button", {username: username.value, subscribeTo: subscribeTo.value,time: `${Date()}`})
    .receive("subscribed" , resp => console.log("subscribed", resp))
    let messageItem = document.createElement("li");
    messageItem.innerText = `${username.value} subscribed to ${subscribeTo.value}`
    msgDiv.appendChild(messageItem)
   }

channel.on("tweet_sub", payload => {
    let messageDiv = document.createElement("div")
    let messageItem = document.createElement("li");  
    let messageButton = document.createElement("button"); 
        
    messageDiv.appendChild(messageItem)
    messageDiv.appendChild(messageButton)    
    messageItem.innerText = `${payload.nodeid} tweeted: ${payload.tweetText}`
    messageButton.innerText = "RETWEET"
    messageButton.style.display = "inline"
    messageButton.addEventListener('click', ()=>{
        channel.push("retweet", {username: username.value, tweetText: payload.tweetText})
    })
    console.log(messageItem.innerText)
    msgDiv.appendChild(messageDiv)
})

document.getElementById('search_hashtag_button').onclick = function () {
    channel.push("search_hashtag", {hashtag: hashtag.value,time: `${Date()}`})
   }

channel.on("search_hashtag", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `tweets with the hashtag ${hashtag.value}:  ${payload.tweet}`
    msgDiv.appendChild(messageItem)
  })

document.getElementById('search_mentions').onclick = function () {
    channel.push("search_usermention", {username: `${username.value}`,time: `${Date()}`})
   }

channel.on("usermention", payload => {
    let messageItem = document.createElement("li");
    console.log(payload.tweet)
    messageItem.innerText = `User mentioned tweets:  ${payload.tweet}`
    msgDiv.appendChild(messageItem)
  })

document.getElementById('search_user_tweets').onclick = function () {
    channel.push("search_usertweets", {username: username.value,time: `${Date()}`})
   }

channel.on("tweetsquery", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `Tweets by user:  ${payload.tweet}`
    msgDiv.appendChild(messageItem)
  })