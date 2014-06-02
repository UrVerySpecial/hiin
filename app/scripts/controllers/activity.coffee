'use strict'

angular.module('hiin').controller 'ActivityCtrl', ($scope, $rootScope, $window, Util, socket, $modal) ->
    socket.emit "activity"
    #scope가 destroy될때, 등록한 이벤트를 모두 지움
    $scope.$on "$destroy", (event) ->
      socket.removeAllListeners()
      return
    socket.emit "myInfo"
    socket.on "myInfo", (data) ->
      console.log "list myInfo"
      $scope.myInfo = data
      $scope.imagePath = Util.serverUrl()+'/'
      return
    socket.on "activity", (data)->
      $scope.rank = data.rank
      $scope.activitys = data.activity
      console.log "activity"
      console.log data
    $scope.okay =->
      console.log 'ih'
    $scope.backToList =->
      $scope.slide = 'slide-right'
      $window.history.back()

    $scope.showRank =->
      modalInstance = $modal.open(
        templateUrl: "views/list/rank_modal.html"
        scope: $scope
      )

    $scope.ShowProfile = (user) ->
      console.log user
      $scope.user = user
      modalInstance = $modal.open(
        templateUrl: "views/chat/user_card.html"
        scope: $scope
      )
      modalInstance.result.then ((selectedItem) ->
        return
      ), ->
        $scope.modalInstance = null
        return
      $scope.modalInstance = modalInstance

    $scope.chatRoom = (user) ->
      console.log(user)
      $scope.slide = 'slide-left'
      if $scope.modalInstance? 
        $scope.modalInstance.close()
      Util.Go('chatRoom/' + user._id )
    $scope.sayHi = (user) ->
      if user.status == '0'
        console.log 'sayhi'
        setTimeout () -> 
          socket.emit "hi" , {
            targetId : user._id
          }, 100000
        return
angular.module('hiin').filter 'convertMsg', () ->
  return (activity) -> 
    if activity.lastMsg.type == 'hi' 
      return 'Sent \'HI\'!'
    else
      return activity.lastMsg.content

angular.module("hiin").directive "ngDisplayYou", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.sender
    if attrs.sender == 'me'
        element.show()
    else
        element.hide()

angular.module("hiin").directive "ngDot", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.read
    if (attrs.read == true)
       element.hide() 
    else
       element.show()
