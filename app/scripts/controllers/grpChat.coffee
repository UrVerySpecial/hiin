'use strict'

angular.module("hiin").controller "grpChatCtrl", ($scope, $modal,$filter,$rootScope, $window, socket, Util,$location,$ionicScrollDelegate,$timeout) ->
  console.log 'grpChat'
  #group chat init
  $scope.data = {}
  $scope.data.message = ""
  $scope.amIOwner = false
  if $window.localStorage?
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    thisEvent = eventInfo.code
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    console.log $scope.myInfo
    if eventInfo.author == $scope.myInfo._id
      $scope.amIOwner = true
      if !$rootScope.regular_msg_flg?
        $rootScope.regular_msg_flg = false
      socket.emit "currentEventUserList"
  messageKey = thisEvent + '_groupMessage'
  $scope.roomName = "GROUP CHAT"
  if $window.localStorage.getItem messageKey
    $scope.messages =  JSON.parse($window.localStorage.getItem messageKey)
  else
    $scope.messages = []
  if $scope.messages.length > 0
    console.log '----unread----'
    console.log 'len:'+$scope.messages.length
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "unread"
                              lastMsgTime: $scope.messages[$scope.messages.length-1].created_at
    }
  else
    console.log '---first entered---'
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "blank"
    }

  $scope.pullLoadMsg =->
    console.log '---pull load msg---'
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "pastThirty"
                              firstMsgTime: $scope.messages[0].created_at
    }
  # socket event ↓
  currentEventUserList = (data) ->
    console.log "list currentEventUserList"
    $scope.userNum = data.length + 1
    console.log data
    return
  userListChange = (data) ->
    console.log 'userListChange'
    $scope.userNum = data.message.usersNumber
    return
  groupMessage = (data) ->
    console.log "grp chat,groupMessage"
    if $scope.myInfo._id == data.sender
      data.sender_name = 'me'
    $scope.messages.push data
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  loadMsgs = (data)->
    if data.message
      data.message.forEach (item)->
        if item.sender is $scope.myInfo._id
          item.sender_name = 'me'
        return
    if data.type is 'group' and data.range is 'all'
      console.log '---all---'
      $scope.messages = data.message
    else if data.type is 'group' and data.range is 'blank'
      console.log '---blank----'
      console.log data
      console.log '--tmper--'
      tempor = $scope.messages.concat data.message.reverse()
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
    else if data.type is 'group' and data.range is 'unread'
      console.log '---unread----'
      console.log data
      tempor = $scope.messages.concat data.message
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
    else if data.type is 'group' and data.range is 'pastThirty'
      console.log '---pastthirty---'
      console.log data.message 
      console.log 'length:'+data.message.length
      tempor = data.message.reverse().concat $scope.messages
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
      $scope.$broadcast('scroll.refreshComplete')
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  socket.on "currentEventUserList", currentEventUserList
  socket.on "userListChange", userListChange
  socket.on "groupMessage", groupMessage
  socket.on 'loadMsgs', loadMsgs
  # ↑
  window.addEventListener "native.keyboardshow", (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if document.activeElement.tagName is "BODY"
      cordova.plugins.Keyboard.close()
      return
    window.scroll(0,0)
    $scope.data.keyboardHeight = e.keyboardHeight
    $timeout (->
      $ionicScrollDelegate.scrollBottom true
      return
    ), 200
    return
  window.addEventListener "native.keyboardhide", (e) ->
    console.log "Keyboard close"
    $scope.data.keyboardHeight = 0
    $ionicScrollDelegate.resize()
    return
  ionic.DomUtil.ready ->
    console.log 'ready'
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
  $scope.$on "$destroy", (event) ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close()
    socket.removeListener("currentEventUserList", currentEventUserList)
    socket.removeListener("userListChange", userListChange)
    socket.removeListener("groupMessage", groupMessage)
    socket.removeListener('loadMsgs', loadMsgs)
    temp = $scope.messages
    len = temp.length
    console.log 'mlen:'+len
    if len > 30
      window.localStorage[messageKey]=JSON.stringify(temp.slice(len-30,temp.length))
    return  
  isIOS = ionic.Platform.isWebView() and ionic.Platform.isIOS()
  $scope.sendMessage =->
    time = new Date()
    if $scope.data.message == ""
      return
    if $scope.amIOwner is true and $rootScope.regular_msg_flg is false
      socket.emit "notice",{
        created_at: time
        message: $scope.data.message
        }
    else
      socket.emit "groupMessage",{
        created_at: time
        message: $scope.data.message
        }
    $scope.data.message = ""
  $scope.inputUp = ->
    console.log 'inputUp'
  $scope.inputDown = ->
    console.log 'inputDown'
    return
  $scope.toggleOwnerMsg = ->
    $rootScope.regular_msg_flg = !$rootScope.regular_msg_flg
    if $rootScope.regular_msg_flg is true
      $scope.popupMessage = "Send as a regular chat message"
    else
      $scope.popupMessage = "Send as a notice to the group"
    $scope.showingMsg = true
    if $scope.timer?
      $timeout.cancel($scope.timer)
    $scope.timer = $timeout (->
      $scope.showingMsg = false
      return
    ), 2000
  #나중에 합치자...
  $scope.ShowProfile = (sender) ->
    listKey = thisEvent + '_currentEventUserList'
    console.log listKey
    users = JSON.parse($window.localStorage.getItem listKey)
    console.log users
    user = $filter('getUserById')(users, sender)
    if user is null
      return
    console.log user
    $scope.user = user
    modalInstance = $modal.open(
      templateUrl: "views/dialog/user_card.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.modalInstance = null
      return
    ), ->
      $scope.modalInstance = null
      return
    $scope.modalInstance = modalInstance
  $scope.sayHi = (user) ->
    if user.status is '0' or user.status is '2'
      console.log 'sayhi'
      setTimeout () -> 
        socket.emit "hi" , {
          targetId : user._id
        }, 100000
      return
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    $location.url('/list/userlists/'+user._id)
  $scope.DialogClose = ->
    $scope.modalInstance.close()