"use strict"

angular.module("hiin").controller "SignUpCtrl", ($modal,$sce,$q,$http,$scope, $window, Util, Host,socket,$state) ->  
  #init
  $scope.photoUrl = 'images/no_image.jpg'
  $scope.imageUploadUrl = "#{Host.getAPIHost()}:#{Host.getAPIPort()}/profileImage"

  $scope.onSuccess = (response) ->
    console.log "onSucess"
    console.log response
    userInfo={}
    userInfo.photoUrl = response.data.photoUrl
    userInfo.thumbnailUrl = response.data.thumbnailUrl
    $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl
    $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl
    $scope.userInfo = userInfo
    angular.element('img.image_upload_btn').attr("src", $scope.thumbnailUrl)
    return

  $scope.makeId = (userInfo) ->
    console.log userInfo
    deferred = $q.defer()
    Util.makeReq('post','user', userInfo)
      .success (data) ->
        if data.status < "0"
          deferred.reject data
        deferred.resolve data
      .error (data, status) ->
        console.log data
        deferred.reject status
    return deferred.promise

  $scope.signUp = (isValid) ->
    console.log isValid
    if isValid == true
      $scope.makeId($scope.userInfo)
        .then (data) ->
          $scope.signIn()
        ,(status) ->
          alert 'err'
        return
    else
      return $scope.showAlert()

  $scope.signIn = ->
    Util.emailLogin($scope.userInfo)
    .then (data) ->
      $state.go('enterEvent')
    , (status) ->
      alert status
    return

  $scope.open = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    $scope.opened = true
    return

  $scope.dateOptions = 
    'year-format': "'yy'"
    'starting-day': 1

  $scope.showAlert = ->
    modalInstance = $modal.open(
      templateUrl: "views/login/alert.html"
      scope: $scope
    )


